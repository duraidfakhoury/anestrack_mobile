import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_cosign_status.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';

/// Either role — "did my scan/attestation work". See
/// `integration-mobile-offline-cosign.md` §6.3.
class GetOfflineCoSignStatusUseCase {
  final ProcedureRepository repository;

  GetOfflineCoSignStatusUseCase(this.repository);

  Future<Either<Failure, OfflineCoSignStatus>> call() {
    return repository.getOfflineCoSignStatus();
  }
}
