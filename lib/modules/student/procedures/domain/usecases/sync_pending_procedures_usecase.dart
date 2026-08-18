import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/core/services/cache_service.dart';
import 'package:anestrack_mobile/core/services/connectivity/connectivity_service.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/pending_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/pending_procedure_repository.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';

class SyncPendingProceduresResult extends Equatable {
  final int succeededCount;
  final int failedCount;
  final bool stoppedEarlyOffline;

  const SyncPendingProceduresResult({
    required this.succeededCount,
    required this.failedCount,
    required this.stoppedEarlyOffline,
  });

  bool get hadWork => succeededCount > 0 || failedCount > 0;

  @override
  List<Object?> get props => [succeededCount, failedCount, stoppedEarlyOffline];
}

/// Drains the local offline queue against the backend. Only ever called by
/// [ProcedureSyncService] — never triggered directly from the UI.
class SyncPendingProceduresUseCase {
  final PendingProcedureRepository pendingRepository;
  final ProcedureRepository procedureRepository;
  final ConnectivityService connectivityService;

  SyncPendingProceduresUseCase(
    this.pendingRepository,
    this.procedureRepository,
    this.connectivityService,
  );

  Future<Either<Failure, SyncPendingProceduresResult>> call() async {
    // Never attempt a sync run against a logged-out session — a 401 here
    // would otherwise permanently mark a perfectly good item `failed` for a
    // reason that has nothing to do with the item itself.
    if (!CacheService().hasToken) {
      return const Right(
        SyncPendingProceduresResult(
          succeededCount: 0,
          failedCount: 0,
          stoppedEarlyOffline: false,
        ),
      );
    }

    final pendingEither = await pendingRepository.listPending();
    Failure? listFailure;
    List<PendingProcedure> items = const [];
    pendingEither.fold((f) => listFailure = f, (list) => items = list);
    if (listFailure != null) return Left(listFailure!);

    if (items.isEmpty) {
      return const Right(
        SyncPendingProceduresResult(
          succeededCount: 0,
          failedCount: 0,
          stoppedEarlyOffline: false,
        ),
      );
    }

    int succeeded = 0;
    int failed = 0;

    for (final item in items) {
      // Re-check before every item, not just once at the top — a flaky
      // connection can flip online->offline mid-loop across several items.
      if (!await connectivityService.isOnline()) {
        return Right(
          SyncPendingProceduresResult(
            succeededCount: succeeded,
            failedCount: failed,
            stoppedEarlyOffline: true,
          ),
        );
      }

      final result = await procedureRepository.createProcedure(
        item.parameters,
      );

      bool isNoInternet = false;
      Failure? itemFailure;
      result.fold((f) {
        itemFailure = f;
        isNoInternet = f is NoInternetFailure;
      }, (_) {});

      if (isNoInternet) {
        // Leave this item untouched (still `pending`) — it just needs a
        // real retry once we're actually back online, not a `failed` mark.
        return Right(
          SyncPendingProceduresResult(
            succeededCount: succeeded,
            failedCount: failed,
            stoppedEarlyOffline: true,
          ),
        );
      }

      if (itemFailure != null) {
        // A real failure (validation, server, parsing, session-expired...).
        // Record it and move on — one bad item must not block the rest.
        failed++;
        await pendingRepository.markFailed(item.localId, itemFailure!.message);
        continue;
      }

      succeeded++;
      await pendingRepository.remove(item.localId);
    }

    return Right(
      SyncPendingProceduresResult(
        succeededCount: succeeded,
        failedCount: failed,
        stoppedEarlyOffline: false,
      ),
    );
  }
}
