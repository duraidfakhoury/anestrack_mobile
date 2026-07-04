import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/supervisor.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/hospital_procedure_type_repository.dart';

class ListSupervisorsUseCase {
  final SupervisorRepository repository;

  ListSupervisorsUseCase(this.repository);

  Future<Either<Failure, List<Supervisor>>> call() {
    return repository.listSupervisors();
  }
}
