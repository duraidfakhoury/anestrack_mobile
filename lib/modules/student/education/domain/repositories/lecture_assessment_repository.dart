import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_result.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_assessment.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/submit_answers_parameters.dart';

abstract class LectureAssessmentRepository {
  /// Returns `null` on the right side when the lecture has no assessment
  /// record yet (distinct from a network/server [Failure]).
  Future<Either<Failure, LectureAssessment?>> getAssessmentForLecture(
    String lectureId,
  );

  Future<Either<Failure, AssessmentResult>> submitAnswers(
    SubmitAnswersParameters params,
  );
}
