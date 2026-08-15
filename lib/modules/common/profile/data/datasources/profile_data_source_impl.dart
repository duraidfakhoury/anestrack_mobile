import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/common/profile/data/datasources/profile_data_source.dart';
import 'package:anestrack_mobile/modules/common/profile/data/models/current_user_model.dart';

class ProfileDataSourceImpl extends ProfileDataSource {
  final Logger _logger = Logger();

  /// `/api/functions/*` strips the Parse `result` wrapper, so the body is the
  /// raw return value. We still tolerate a `{result: ...}` envelope defensively.
  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  @override
  Future<CurrentUserModel> getCurrentUser() async {
    try {
      _logger.i('Fetching current user');
      final response = await NetworkHelper().get(ApisUrls().getCurrentUser);
      final body = _unwrap(response.data);
      if (body is Map) {
        return CurrentUserModel.fromJson(Map<String, dynamic>.from(body));
      }
      throw Exception('Unexpected getCurrentUser response: ${response.data}');
    } catch (e) {
      _logger.e('Failed to fetch current user: $e');
      rethrow;
    }
  }
}
