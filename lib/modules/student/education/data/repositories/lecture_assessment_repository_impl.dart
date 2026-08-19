import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
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
}
