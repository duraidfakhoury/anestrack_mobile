import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/core/services/cache_service.dart';
import 'package:anestrack_mobile/core/services/connectivity/connectivity_service.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_attestation_submit_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/offline_attestation_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/submit_offline_attestations_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/domain/entities/offline_attestation.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/domain/repositories/offline_attestation_repository.dart';

class SubmitOfflineAttestationsResult extends Equatable {
  final int successCount;
  final int failureCount;
  final int matchedCount;
  final bool stoppedEarlyOffline;

  const SubmitOfflineAttestationsResult({
    required this.successCount,
    required this.failureCount,
    required this.matchedCount,
    required this.stoppedEarlyOffline,
  });

  bool get hadWork => successCount > 0 || failureCount > 0;

  @override
  List<Object?> get props => [
    successCount,
    failureCount,
    matchedCount,
    stoppedEarlyOffline,
  ];
}

/// Drains the local attestation outbox against the backend in one batch
/// call. Only ever called by `OfflineAttestationSyncService` — never
/// triggered directly from the UI.
class SubmitOfflineAttestationsUseCase {
  final OfflineAttestationRepository attestationRepository;
  final ProcedureRepository procedureRepository;
  final ConnectivityService connectivityService;

  SubmitOfflineAttestationsUseCase(
    this.attestationRepository,
    this.procedureRepository,
    this.connectivityService,
  );

  static const _empty = SubmitOfflineAttestationsResult(
    successCount: 0,
    failureCount: 0,
    matchedCount: 0,
    stoppedEarlyOffline: false,
  );

  Future<Either<Failure, SubmitOfflineAttestationsResult>> call() async {
    // Never attempt a submit run against a logged-out session — a 401 here
    // would otherwise permanently mark perfectly good rows `failed` for a
    // reason that has nothing to do with them.
    if (!CacheService().hasToken) return const Right(_empty);

    final pendingEither = await attestationRepository.listPending();
    Failure? listFailure;
    List<OfflineAttestation> items = const [];
    pendingEither.fold((f) => listFailure = f, (list) => items = list);
    if (listFailure != null) return Left(listFailure!);
    if (items.isEmpty) return const Right(_empty);

    if (!await connectivityService.isOnline()) {
      return const Right(
        SubmitOfflineAttestationsResult(
          successCount: 0,
          failureCount: 0,
          matchedCount: 0,
          stoppedEarlyOffline: true,
        ),
      );
    }

    final params = SubmitOfflineAttestationsParameters(
      items
          .map(
            (e) => OfflineAttestationParameters(
              localId: e.localId,
              coSignCode: e.code,
              witnessedAt: e.witnessedAt,
              note: e.note,
            ),
          )
          .toList(),
    );

    final submitEither = await procedureRepository.submitOfflineAttestations(
      params,
    );

    Failure? topFailure;
    List<OfflineAttestationSubmitResultRow> resultRows = const [];
    submitEither.fold((f) => topFailure = f, (r) => resultRows = r.results);

    if (topFailure is NoInternetFailure) {
      // Leave every row untouched — it just needs a real retry once we're
      // actually back online.
      return const Right(
        SubmitOfflineAttestationsResult(
          successCount: 0,
          failureCount: 0,
          matchedCount: 0,
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
    int matched = 0;

    for (final row in resultRows) {
      if (row.index < 0 || row.index >= items.length) continue;
      final item = items[row.index];

      // `matched: false` is the normal "supervisor synced first" outcome,
      // not a failure — either way the upload itself succeeded, so delete
      // the local code (spec rule §8.6). Only a real per-row failure keeps
      // the row queued for retry.
      if (row.success || row.alreadySubmitted) {
        succeeded++;
        if (row.matched) matched++;
        await attestationRepository.remove(item.localId);
      } else {
        failed++;
        await attestationRepository.markFailed(
          item.localId,
          row.detail ?? 'Attestation submission failed',
        );
      }
    }

    return Right(
      SubmitOfflineAttestationsResult(
        successCount: succeeded,
        failureCount: failed,
        matchedCount: matched,
        stoppedEarlyOffline: false,
      ),
    );
  }
}
