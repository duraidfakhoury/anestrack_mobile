import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/confirm_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';

class ConfirmProcedureUseCase {
  final ProcedureRepository repository;

  ConfirmProcedureUseCase(this.repository);

  Future<Either<Failure, Procedure>> call(
    ConfirmProcedureParameters parameters,
  ) {
    return repository.confirmProcedure(parameters);
  }
}
