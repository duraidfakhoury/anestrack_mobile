import 'package:anestrack_mobile/modules/student/education/data/models/ai_summary_model.dart';

abstract class AiSummaryDataSource {
  Future<AiSummaryModel> generateAiSummary({
    required String lectureId,
    required bool regenerate,
  });
}
