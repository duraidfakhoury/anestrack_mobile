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

  /// The graded review with breakdown. Returns `null` on the right side when
  /// the student has not submitted yet (Parse code 101) — the caller uses that
  /// to switch between "Take the test" and "Review" (integration §11/§15).
  Future<Either<Failure, AssessmentResult?>> getAssessmentResult({
    required String assessmentId,
    String? studentId,
  });
}
