import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/ai_summary.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/generate_ai_summary_parameters.dart';

abstract class AiSummaryRepository {
  Future<Either<Failure, AiSummary>> generateAiSummary(
    GenerateAiSummaryParameters params,
  );
}
