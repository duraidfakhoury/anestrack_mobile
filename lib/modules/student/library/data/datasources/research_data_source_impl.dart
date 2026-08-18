import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/student/library/data/datasources/research_data_source.dart';
import 'package:anestrack_mobile/modules/student/library/data/models/research_paper_model.dart';

class ResearchDataSourceImpl extends ResearchDataSource {
  final Logger _logger = Logger();

  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  @override
  Future<List<ResearchPaperModel>> listResearchPapers({
    int? limit,
    int? skip,
  }) async {
    try {
      _logger.i('Fetching research papers');
      final response = await NetworkHelper().get(
        ApisUrls().listResearchPapers,
        data: {
          if (limit != null) 'limit': limit,
          if (skip != null) 'skip': skip,
        },
      );
      final body = _unwrap(response.data);
      if (body is List) {
        return body
            .whereType<Map>()
            .map(
              (e) => ResearchPaperModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      }
      _logger.w('Unexpected research papers response: ${response.data}');
      return [];
    } catch (e) {
      _logger.e('Failed to fetch research papers: $e');
      rethrow;
    }
  }
}
