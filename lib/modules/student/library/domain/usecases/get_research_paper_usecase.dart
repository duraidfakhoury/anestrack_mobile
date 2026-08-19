import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/domain/repositories/research_repository.dart';

class GetResearchPaperUseCase {
  final ResearchRepository repository;

  GetResearchPaperUseCase(this.repository);

  Future<Either<Failure, ResearchPaper>> call(String id) =>
      repository.getResearchPaper(id);
}
