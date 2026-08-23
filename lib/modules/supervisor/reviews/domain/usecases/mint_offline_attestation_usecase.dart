import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/domain/entities/offline_attestation.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/domain/repositories/offline_attestation_repository.dart';

/// "Witness a procedure": mints a bedside attestation and persists it before
/// the caller renders the QR. See [OfflineAttestationRepository.mintAndEnqueue].
class MintOfflineAttestationUseCase {
  final OfflineAttestationRepository repository;

  MintOfflineAttestationUseCase(this.repository);

  Future<Either<Failure, OfflineAttestation>> call({String? note}) {
    return repository.mintAndEnqueue(note: note);
  }
}
