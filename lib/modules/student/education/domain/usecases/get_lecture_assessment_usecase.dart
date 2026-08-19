import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_assessment.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_assessment_repository.dart';

class GetLectureAssessmentUseCase {
  final LectureAssessmentRepository repository;

  GetLectureAssessmentUseCase(this.repository);

  Future<Either<Failure, LectureAssessment?>> call(String lectureId) =>
      repository.getAssessmentForLecture(lectureId);
}
