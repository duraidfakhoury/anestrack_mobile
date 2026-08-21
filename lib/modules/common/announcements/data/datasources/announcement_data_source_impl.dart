import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/common/announcements/data/datasources/announcement_data_source.dart';
import 'package:anestrack_mobile/modules/common/announcements/data/models/announcement_model.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/parameters/create_announcement_parameters.dart';

class AnnouncementDataSourceImpl extends AnnouncementDataSource {
  final Logger _logger = Logger();

  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  @override
  Future<List<AnnouncementModel>> listAnnouncements({
    int? limit,
    int? skip,
  }) async {
    try {
      _logger.i('Fetching announcements');
      final response = await NetworkHelper().get(
        ApisUrls().listAnnouncements,
        data: {
          if (limit != null) 'limit': limit,
          if (skip != null) 'skip': skip,
        },
      );
      _logger.i('${response.statusCode} ${response.data}');

      final body = _unwrap(response.data);
      if (body is List) {
        return body
            .whereType<Map>()
            .map(
              (e) => AnnouncementModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      }
      _logger.w('Unexpected announcements response: ${response.data}');
      return [];
    } catch (e) {
      _logger.e('Failed to fetch announcements: $e');
      rethrow;
    }
  }

  @override
  Future<AnnouncementModel> createAnnouncement(
    CreateAnnouncementParameters parameters,
  ) async {
    try {
      _logger.i('Creating announcement "${parameters.title}"');
      final response = await NetworkHelper().post(
        ApisUrls().createAnnouncement,
        data: parameters.toJson(),
      );
      final body = _unwrap(response.data);
      if (body is Map) {
        return AnnouncementModel.fromJson(Map<String, dynamic>.from(body));
      }
      throw Exception('Unexpected create announcement response: ${response.data}');
    } catch (e) {
      _logger.e('Failed to create announcement: $e');
      rethrow;
    }
  }
}
