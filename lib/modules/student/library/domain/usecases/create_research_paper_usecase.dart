import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_parameters.dart';
import 'package:anestrack_mobile/modules/student/library/domain/repositories/research_repository.dart';

class CreateResearchPaperUseCase {
  final ResearchRepository repository;

  CreateResearchPaperUseCase(this.repository);

  Future<Either<Failure, ResearchPaper>> call(
    CreateResearchPaperParameters parameters,
  ) => repository.createResearchPaper(parameters);
}
