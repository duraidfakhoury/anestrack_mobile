import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/create_lecture_evaluation_parameters.dart';

abstract class LectureEvaluationRepository {
  Future<Either<Failure, Unit>> createEvaluation(
    CreateLectureEvaluationParameters parameters,
  );
}
