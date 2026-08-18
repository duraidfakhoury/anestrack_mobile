import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/pending_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/pending_procedure_repository.dart';

class ListPendingProceduresUseCase {
  final PendingProcedureRepository repository;

  ListPendingProceduresUseCase(this.repository);

  Future<Either<Failure, List<PendingProcedure>>> call() {
    return repository.listPending();
  }
}
