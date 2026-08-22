import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_result.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_assessment_repository.dart';

class GetAssessmentResultUseCase {
  final LectureAssessmentRepository repository;

  GetAssessmentResultUseCase(this.repository);

  /// `null` on the right side → the student has not submitted yet.
  Future<Either<Failure, AssessmentResult?>> call({
    required String assessmentId,
    String? studentId,
  }) => repository.getAssessmentResult(
    assessmentId: assessmentId,
    studentId: studentId,
  );
}
