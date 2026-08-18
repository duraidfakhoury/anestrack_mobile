import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/pending_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';

/// Local-only queue of procedures awaiting sync. Distinct from
/// [ProcedureRepository], which talks to the backend.
abstract class PendingProcedureRepository {
  Future<Either<Failure, PendingProcedure>> enqueue(
    CreateProcedureParameters parameters,
  );

  Future<Either<Failure, List<PendingProcedure>>> listPending();

  Future<Either<Failure, void>> remove(String localId);

  Future<Either<Failure, void>> markFailed(String localId, String errorMessage);
}
