import 'package:anestrack_mobile/modules/common/notifications/data/models/app_notification_model.dart';

abstract class NotificationDataSource {
  Future<List<AppNotificationModel>> listNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
