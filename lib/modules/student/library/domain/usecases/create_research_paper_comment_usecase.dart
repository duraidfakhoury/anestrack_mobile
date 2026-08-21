import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper_comment.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_comment_parameters.dart';
import 'package:anestrack_mobile/modules/student/library/domain/repositories/research_repository.dart';

class CreateResearchPaperCommentUseCase {
  final ResearchRepository repository;

  CreateResearchPaperCommentUseCase(this.repository);

  Future<Either<Failure, ResearchPaperComment>> call(
    CreateResearchPaperCommentParameters parameters,
  ) => repository.createResearchPaperComment(parameters);
}
