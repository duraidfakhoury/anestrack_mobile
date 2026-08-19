import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/student/library/data/datasources/research_type_data_source.dart';
import 'package:anestrack_mobile/modules/student/library/data/models/research_type_model.dart';

class ResearchTypeDataSourceImpl extends ResearchTypeDataSource {
  final Logger _logger = Logger();

  @override
  Future<List<ResearchTypeModel>> listResearchTypes() async {
    try {
      _logger.i('Fetching research types');
      final response = await NetworkHelper().get(ApisUrls().listResearchTypes);

      List<dynamic>? rawList;
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['result'] is List) {
          rawList = data['result'] as List;
        }
      }

      if (rawList != null) {
        return rawList
            .whereType<Map>()
            .map(
              (e) => ResearchTypeModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      }
      _logger.w('Unexpected research types response: ${response.data}');
      return [];
    } catch (e) {
      _logger.e('Failed to fetch research types: $e');
      rethrow;
    }
  }
}
