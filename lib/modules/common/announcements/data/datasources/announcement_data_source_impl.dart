import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/common/announcements/data/datasources/announcement_data_source.dart';
import 'package:anestrack_mobile/modules/common/announcements/data/models/announcement_model.dart';

class AnnouncementDataSourceImpl extends AnnouncementDataSource {
  final Logger _logger = Logger();

  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  @override
  Future<List<AnnouncementModel>> listAnnouncements() async {
    try {
      _logger.i('Fetching announcements');
      final response = await NetworkHelper().get(ApisUrls().listAnnouncements);
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
}
