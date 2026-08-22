import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/evaluation_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';

class CreateEvaluationUseCase {
  final ProcedureRepository repository;

  CreateEvaluationUseCase(this.repository);

  Future<Either<Failure, bool>> call(EvaluationParameters parameters) {
    return repository.createEvaluation(parameters);
  }
}
