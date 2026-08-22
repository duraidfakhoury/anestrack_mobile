import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_evaluation_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/create_lecture_evaluation_parameters.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_evaluation_repository.dart';

class LectureEvaluationRepositoryImpl extends LectureEvaluationRepository {
  final LectureEvaluationDataSource dataSource;

  LectureEvaluationRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Unit>> createEvaluation(
    CreateLectureEvaluationParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(() async {
      await dataSource.createEvaluation(parameters);
      return unit;
    });
  }
}
