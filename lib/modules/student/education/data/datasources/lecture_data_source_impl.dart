import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/data/models/lecture_model.dart';

class LectureDataSourceImpl extends LectureDataSource {
  final Logger _logger = Logger();

  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  @override
  Future<List<LectureModel>> listLectures({int? limit, int? skip}) async {
    try {
      _logger.i('Fetching lectures');
      final response = await NetworkHelper().get(
        ApisUrls().listLectures,
        data: {
          if (limit != null) 'limit': limit,
          if (skip != null) 'skip': skip,
        },
      );
      final body = _unwrap(response.data);
      if (body is List) {
        return body
            .whereType<Map>()
            .map((e) => LectureModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      _logger.w('Unexpected lectures response: ${response.data}');
      return [];
    } catch (e) {
      _logger.e('Failed to fetch lectures: $e');
      rethrow;
    }
  }
}
