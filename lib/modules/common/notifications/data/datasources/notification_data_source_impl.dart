import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/common/notifications/data/datasources/notification_data_source.dart';
import 'package:anestrack_mobile/modules/common/notifications/data/models/app_notification_model.dart';

class NotificationDataSourceImpl extends NotificationDataSource {
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
  Future<List<AppNotificationModel>> listNotifications() async {
    try {
      _logger.i('Fetching notifications');
      final response = await NetworkHelper().get(ApisUrls().listNotifications);
      final body = _unwrap(response.data);
      if (body is List) {
        return body
            .whereType<Map>()
            .map(
              (e) => AppNotificationModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      }
      _logger.w('Unexpected notifications response: ${response.data}');
      return [];
    } catch (e) {
      _logger.e('Failed to fetch notifications: $e');
      rethrow;
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await NetworkHelper().get(ApisUrls().getUnreadCount);
      final body = _unwrap(response.data);
      if (body is Map && body['count'] != null) {
        return (body['count'] as num).toInt();
      }
      return 0;
    } catch (e) {
      _logger.e('Failed to fetch unread count: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await NetworkHelper().put(
        ApisUrls().markNotificationAsRead,
        data: {'id': id},
      );
    } catch (e) {
      _logger.e('Failed to mark notification as read: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await NetworkHelper().put(ApisUrls().markAllNotificationsAsRead);
    } catch (e) {
      _logger.e('Failed to mark all notifications as read: $e');
      rethrow;
    }
  }
}
