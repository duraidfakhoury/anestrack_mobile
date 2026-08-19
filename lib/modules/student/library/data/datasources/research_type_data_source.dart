import 'package:anestrack_mobile/modules/student/library/data/models/research_type_model.dart';

abstract class ResearchTypeDataSource {
  Future<List<ResearchTypeModel>> listResearchTypes();
}
