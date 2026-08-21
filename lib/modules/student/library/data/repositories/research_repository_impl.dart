import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/library/data/datasources/research_data_source.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper_comment.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_comment_parameters.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_parameters.dart';
import 'package:anestrack_mobile/modules/student/library/domain/repositories/research_repository.dart';

class ResearchRepositoryImpl extends ResearchRepository {
  final ResearchDataSource dataSource;

  ResearchRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ResearchPaper>>> listResearchPapers({
    int? limit,
    int? skip,
  }) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.listResearchPapers(limit: limit, skip: skip),
    );
  }

  @override
  Future<Either<Failure, ResearchPaper>> getResearchPaper(String id) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.getResearchPaper(id),
    );
  }

  @override
  Future<Either<Failure, ResearchPaper>> createResearchPaper(
    CreateResearchPaperParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.createResearchPaper(parameters),
    );
  }

  @override
  Future<Either<Failure, List<ResearchPaperComment>>> listResearchPaperComments(
    String paperId,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.listResearchPaperComments(paperId),
    );
  }

  @override
  Future<Either<Failure, ResearchPaperComment>> createResearchPaperComment(
    CreateResearchPaperCommentParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.createResearchPaperComment(parameters),
    );
  }
}
