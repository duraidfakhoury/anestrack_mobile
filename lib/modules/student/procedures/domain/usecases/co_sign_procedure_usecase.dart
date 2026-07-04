import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/co_sign_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';

class CoSignProcedureUseCase {
  final ProcedureRepository repository;

  CoSignProcedureUseCase(this.repository);

  Future<Either<Failure, Procedure>> call(CoSignParameters parameters) {
    return repository.coSignProcedure(parameters);
  }
}
