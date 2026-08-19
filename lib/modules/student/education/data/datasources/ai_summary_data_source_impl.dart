import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/ai_summary_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/data/models/ai_summary_model.dart';

class AiSummaryDataSourceImpl extends AiSummaryDataSource {
  final Logger _logger = Logger();

  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  @override
  Future<AiSummaryModel> generateAiSummary({
    required String lectureId,
    required bool regenerate,
  }) async {
    try {
      _logger.i('Generating AI summary for lecture $lectureId');
      final response = await NetworkHelper().post(
        ApisUrls().generateAISummary,
        data: {'lectureId': lectureId, 'regenerate': regenerate.toString()},
      );
      final body = _unwrap(response.data);
      return AiSummaryModel.fromJson(Map<String, dynamic>.from(body as Map));
    } catch (e) {
      _logger.e('Failed to generate AI summary for lecture $lectureId: $e');
      rethrow;
    }
  }
}
