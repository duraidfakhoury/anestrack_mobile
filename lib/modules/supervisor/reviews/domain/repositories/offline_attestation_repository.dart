import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/domain/entities/offline_attestation.dart';

/// Local-only outbox of minted attestations awaiting submission. Distinct
/// from `ProcedureRepository`, which talks to the backend.
abstract class OfflineAttestationRepository {
  /// Mints `localId`/`code`/`witnessedAt` and persists the row *before*
  /// returning — the caller must await this and only then render the QR
  /// (spec rule §8.3: an app kill while the QR is on screen must not lose
  /// an attestation the student already scanned).
  Future<Either<Failure, OfflineAttestation>> mintAndEnqueue({String? note});

  Future<Either<Failure, List<OfflineAttestation>>> listPending();

  Future<Either<Failure, void>> remove(String localId);

  Future<Either<Failure, void>> markFailed(String localId, String errorMessage);
}
