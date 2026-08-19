import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/ai_summary_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/ai_summary.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/generate_ai_summary_parameters.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/ai_summary_repository.dart';

class AiSummaryRepositoryImpl extends AiSummaryRepository {
  final AiSummaryDataSource dataSource;

  AiSummaryRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, AiSummary>> generateAiSummary(
    GenerateAiSummaryParameters params,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.generateAiSummary(
        lectureId: params.lectureId,
        regenerate: params.regenerate,
      ),
    );
  }
}
