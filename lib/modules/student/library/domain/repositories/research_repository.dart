import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper_comment.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_comment_parameters.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_parameters.dart';

abstract class ResearchRepository {
  Future<Either<Failure, List<ResearchPaper>>> listResearchPapers({
    int? limit,
    int? skip,
  });

  Future<Either<Failure, ResearchPaper>> getResearchPaper(String id);

  Future<Either<Failure, ResearchPaper>> createResearchPaper(
    CreateResearchPaperParameters parameters,
  );

  Future<Either<Failure, List<ResearchPaperComment>>> listResearchPaperComments(
    String paperId,
  );

  Future<Either<Failure, ResearchPaperComment>> createResearchPaperComment(
    CreateResearchPaperCommentParameters parameters,
  );
}
