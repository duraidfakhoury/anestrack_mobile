import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/exception.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_assessment_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_result.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_assessment.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/submit_answers_parameters.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_assessment_repository.dart';

class LectureAssessmentRepositoryImpl extends LectureAssessmentRepository {
  final LectureAssessmentDataSource dataSource;

  LectureAssessmentRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, LectureAssessment?>> getAssessmentForLecture(
    String lectureId,
  ) {
    return AppErrorsHandler().defaultHandleEither(() async {
      final list = await dataSource.listLectureAssessments(
        lectureId: lectureId,
        limit: 1,
      );
      return list.isEmpty ? null : list.first;
    });
  }

  @override
  Future<Either<Failure, AssessmentResult>> submitAnswers(
    SubmitAnswersParameters params,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.submitAnswers(
        assessmentId: params.assessmentId,
        answers: params.answers,
      ),
    );
  }

  @override
  Future<Either<Failure, AssessmentResult?>> getAssessmentResult({
    required String assessmentId,
    String? studentId,
  }) {
    return AppErrorsHandler().defaultHandleEither<AssessmentResult?>(() async {
      try {
        return await dataSource.getAssessmentResult(
          assessmentId: assessmentId,
          studentId: studentId,
        );
      } on ServerException catch (e) {
        // Parse code 101 "No submission found for this assessment" — the
        // student hasn't taken it yet. Surface as null rather than a Failure
        // (integration §11). Parse's numeric code isn't preserved, so match
        // the error message the backend sends.
        final msg = e.errorMessageModel.statusMessage.toLowerCase();
        if (msg.contains('no submission') || msg.contains('not found')) {
          return null;
        }
        rethrow;
      }
    });
  }
}
