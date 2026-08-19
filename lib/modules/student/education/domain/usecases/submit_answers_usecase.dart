import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_result.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/submit_answers_parameters.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_assessment_repository.dart';

class SubmitAnswersUseCase {
  final LectureAssessmentRepository repository;

  SubmitAnswersUseCase(this.repository);

  Future<Either<Failure, AssessmentResult>> call(
    SubmitAnswersParameters params,
  ) => repository.submitAnswers(params);
}
