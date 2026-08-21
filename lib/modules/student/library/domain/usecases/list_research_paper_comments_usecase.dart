import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper_comment.dart';
import 'package:anestrack_mobile/modules/student/library/domain/repositories/research_repository.dart';

class ListResearchPaperCommentsUseCase {
  final ResearchRepository repository;

  ListResearchPaperCommentsUseCase(this.repository);

  Future<Either<Failure, List<ResearchPaperComment>>> call(String paperId) =>
      repository.listResearchPaperComments(paperId);
}
