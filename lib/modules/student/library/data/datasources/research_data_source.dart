import 'package:anestrack_mobile/modules/student/library/data/models/research_paper_comment_model.dart';
import 'package:anestrack_mobile/modules/student/library/data/models/research_paper_model.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_comment_parameters.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_parameters.dart';

abstract class ResearchDataSource {
  Future<List<ResearchPaperModel>> listResearchPapers({int? limit, int? skip});

  Future<ResearchPaperModel> getResearchPaper(String id);

  Future<ResearchPaperModel> createResearchPaper(
    CreateResearchPaperParameters parameters,
  );

  Future<List<ResearchPaperCommentModel>> listResearchPaperComments(
    String paperId,
  );

  Future<ResearchPaperCommentModel> createResearchPaperComment(
    CreateResearchPaperCommentParameters parameters,
  );
}
