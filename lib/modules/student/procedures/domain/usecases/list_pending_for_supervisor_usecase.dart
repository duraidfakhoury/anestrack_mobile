import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';

class ListPendingForSupervisorUseCase {
  final ProcedureRepository repository;

  ListPendingForSupervisorUseCase(this.repository);

  Future<Either<Failure, List<Procedure>>> call() {
    return repository.listPendingForSupervisor();
  }
}
