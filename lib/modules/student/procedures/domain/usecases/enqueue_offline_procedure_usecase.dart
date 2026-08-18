import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/pending_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/pending_procedure_repository.dart';

class EnqueueOfflineProcedureUseCase {
  final PendingProcedureRepository repository;

  EnqueueOfflineProcedureUseCase(this.repository);

  Future<Either<Failure, PendingProcedure>> call(
    CreateProcedureParameters parameters,
  ) {
    // Reaching this use case means the device genuinely had no connectivity
    // at submission time, so `isOffline` (the "no connectivity at point of
    // care" signal) is set automatically here rather than left to a manual
    // toggle. `requestLiveCoSign` is stripped too — a live co-sign handoff
    // can't happen without a live round trip to the backend for the code,
    // and the point-of-care moment will have passed by the time this syncs
    // later, so keeping it would just generate a code nobody can use.
    final queuedParameters = parameters.copyWith(
      isOffline: true,
      requestLiveCoSign: false,
    );
    return repository.enqueue(queuedParameters);
  }
}
