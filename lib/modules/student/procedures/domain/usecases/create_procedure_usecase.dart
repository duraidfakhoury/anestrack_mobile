import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';

class CreateProcedureUseCase {
  final ProcedureRepository repository;

  CreateProcedureUseCase(this.repository);

  Future<Either<Failure, CreateProcedureResult>> call(
    CreateProcedureParameters parameters,
  ) {
    return repository.createProcedure(parameters);
  }
}
