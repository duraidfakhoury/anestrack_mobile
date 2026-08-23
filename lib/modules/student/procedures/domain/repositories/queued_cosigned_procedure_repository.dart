import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/queued_cosigned_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/offline_cosigned_procedure_parameters.dart';

/// Local-only queue of co-signed offline entries awaiting sync. Distinct
/// from `PendingProcedureRepository` (see `integration-mobile-offline-cosign.md`
/// §10) and from `ProcedureRepository`, which talks to the backend.
abstract class QueuedCosignedProcedureRepository {
  Future<Either<Failure, QueuedCosignedProcedure>> enqueue(
    OfflineCosignedProcedureParameters parameters,
  );

  Future<Either<Failure, List<QueuedCosignedProcedure>>> listPending();

  Future<Either<Failure, void>> remove(String localId);

  Future<Either<Failure, void>> markFailed(String localId, String errorMessage);
}
