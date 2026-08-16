import 'package:anestrack_mobile/modules/student/library/data/models/research_paper_model.dart';

abstract class ResearchDataSource {
  Future<List<ResearchPaperModel>> listResearchPapers();
}
