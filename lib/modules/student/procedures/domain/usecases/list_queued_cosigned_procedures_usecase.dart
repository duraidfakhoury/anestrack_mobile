import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/queued_cosigned_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/queued_cosigned_procedure_repository.dart';

class ListQueuedCosignedProceduresUseCase {
  final QueuedCosignedProcedureRepository repository;

  ListQueuedCosignedProceduresUseCase(this.repository);

  Future<Either<Failure, List<QueuedCosignedProcedure>>> call() {
    return repository.listPending();
  }
}
