import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/domain/repositories/research_repository.dart';

class ListResearchPapersUseCase {
  final ResearchRepository repository;

  ListResearchPapersUseCase(this.repository);

  Future<Either<Failure, List<ResearchPaper>>> call() =>
      repository.listResearchPapers();
}
