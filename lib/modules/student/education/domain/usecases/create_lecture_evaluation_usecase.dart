import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/create_lecture_evaluation_parameters.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_evaluation_repository.dart';

class CreateLectureEvaluationUseCase {
  final LectureEvaluationRepository repository;

  CreateLectureEvaluationUseCase(this.repository);

  Future<Either<Failure, Unit>> call(
    CreateLectureEvaluationParameters parameters,
  ) => repository.createEvaluation(parameters);
}
