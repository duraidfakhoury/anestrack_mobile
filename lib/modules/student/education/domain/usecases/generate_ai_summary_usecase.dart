import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/ai_summary.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/generate_ai_summary_parameters.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/ai_summary_repository.dart';

class GenerateAiSummaryUseCase {
  final AiSummaryRepository repository;

  GenerateAiSummaryUseCase(this.repository);

  Future<Either<Failure, AiSummary>> call(GenerateAiSummaryParameters params) =>
      repository.generateAiSummary(params);
}
