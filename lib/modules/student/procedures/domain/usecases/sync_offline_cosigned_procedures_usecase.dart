import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/core/services/cache_service.dart';
import 'package:anestrack_mobile/core/services/connectivity/connectivity_service.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_cosign_sync_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/queued_cosigned_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/sync_offline_cosigned_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/queued_cosigned_procedure_repository.dart';

class SyncOfflineCosignedProceduresResult extends Equatable {
  final int successCount;
  final int failureCount;
  final int coSignedCount;
  final int pendingCount;
  final bool stoppedEarlyOffline;

  const SyncOfflineCosignedProceduresResult({
    required this.successCount,
    required this.failureCount,
    required this.coSignedCount,
    required this.pendingCount,
    required this.stoppedEarlyOffline,
  });

  bool get hadWork => successCount > 0 || failureCount > 0;

  @override
  List<Object?> get props => [
    successCount,
    failureCount,
    coSignedCount,
    pendingCount,
    stoppedEarlyOffline,
  ];
}

/// Drains the local co-signed-procedure queue against the backend in one
/// batch call ("one request may carry many bedside events", spec §5). Only
/// ever called by `OfflineCosignedProcedureSyncService` — never triggered
/// directly from the UI.
class SyncOfflineCoSignedProceduresUseCase {
  final QueuedCosignedProcedureRepository queueRepository;
  final ProcedureRepository procedureRepository;
  final ConnectivityService connectivityService;

  SyncOfflineCoSignedProceduresUseCase(
    this.queueRepository,
    this.procedureRepository,
    this.connectivityService,
  );

  static const _empty = SyncOfflineCosignedProceduresResult(
    successCount: 0,
    failureCount: 0,
    coSignedCount: 0,
    pendingCount: 0,
    stoppedEarlyOffline: false,
  );

  Future<Either<Failure, SyncOfflineCosignedProceduresResult>> call() async {
    // Never attempt a sync run against a logged-out session — a 401 here
    // would otherwise permanently mark perfectly good rows `failed` for a
    // reason that has nothing to do with them.
    if (!CacheService().hasToken) return const Right(_empty);

    final pendingEither = await queueRepository.listPending();
    Failure? listFailure;
    List<QueuedCosignedProcedure> items = const [];
    pendingEither.fold((f) => listFailure = f, (list) => items = list);
    if (listFailure != null) return Left(listFailure!);
    if (items.isEmpty) return const Right(_empty);

    if (!await connectivityService.isOnline()) {
      return const Right(
        SyncOfflineCosignedProceduresResult(
          successCount: 0,
          failureCount: 0,
          coSignedCount: 0,
          pendingCount: 0,
          stoppedEarlyOffline: true,
        ),
      );
    }

    final params = SyncOfflineCosignedProceduresParameters(
      items.map((e) => e.parameters).toList(),
    );

    final syncEither = await procedureRepository.syncOfflineCoSignedProcedures(
      params,
    );

    Failure? topFailure;
    List<OfflineCoSignSyncResultRow> resultRows = const [];
    syncEither.fold((f) => topFailure = f, (r) => resultRows = r.results);

    if (topFailure is NoInternetFailure) {
      // Leave every row untouched — it just needs a real retry once we're
      // actually back online.
      return const Right(
        SyncOfflineCosignedProceduresResult(
          successCount: 0,
          failureCount: 0,
          coSignedCount: 0,
          pendingCount: 0,
          stoppedEarlyOffline: true,
        ),
      );
    }
    if (topFailure != null) {
      // A whole-request failure (validation/server/parsing) — nothing was
      // matched by index, so leave every row queued for the next attempt.
      return Left(topFailure!);
    }

    int succeeded = 0;
    int failed = 0;
    int coSigned = 0;
    int pending = 0;

    for (final row in resultRows) {
      if (row.index < 0 || row.index >= items.length) continue;
      final item = items[row.index];

      // `coSignPending: true` is the normal "student synced first" outcome,
      // not a failure — the upload itself succeeded either way, so clear
      // the local queue row. Only a real per-row failure keeps it queued.
      if (row.success || row.alreadySynced) {
        succeeded++;
        if (row.coSigned) coSigned++;
        if (row.coSignPending) pending++;
        await queueRepository.remove(item.localId);
      } else {
        failed++;
        await queueRepository.markFailed(
          item.localId,
          row.detail ?? 'Offline co-sign sync failed',
        );
      }
    }

    return Right(
      SyncOfflineCosignedProceduresResult(
        successCount: succeeded,
        failureCount: failed,
        coSignedCount: coSigned,
        pendingCount: pending,
        stoppedEarlyOffline: false,
      ),
    );
  }
}
