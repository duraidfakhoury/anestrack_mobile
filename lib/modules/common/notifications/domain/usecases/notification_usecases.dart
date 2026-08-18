import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/entities/app_notification.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/repositories/notification_repository.dart';

class ListNotificationsUseCase {
  final NotificationRepository repository;
  ListNotificationsUseCase(this.repository);

  Future<Either<Failure, List<AppNotification>>> call({
    int? limit,
    int? skip,
  }) => repository.listNotifications(limit: limit, skip: skip);
}

class GetUnreadCountUseCase {
  final NotificationRepository repository;
  GetUnreadCountUseCase(this.repository);

  Future<Either<Failure, int>> call() => repository.getUnreadCount();
}

class MarkNotificationReadUseCase {
  final NotificationRepository repository;
  MarkNotificationReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String id) => repository.markAsRead(id);
}

class MarkAllNotificationsReadUseCase {
  final NotificationRepository repository;
  MarkAllNotificationsReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call() => repository.markAllAsRead();
}
