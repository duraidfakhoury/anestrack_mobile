import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/common/notifications/data/datasources/notification_data_source.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/entities/app_notification.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl extends NotificationRepository {
  final NotificationDataSource dataSource;

  NotificationRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<AppNotification>>> listNotifications({
    int? limit,
    int? skip,
  }) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.listNotifications(limit: limit, skip: skip),
    );
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.getUnreadCount(),
    );
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String id) {
    return AppErrorsHandler().defaultHandleEither(() async {
      await dataSource.markAsRead(id);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead() {
    return AppErrorsHandler().defaultHandleEither(() async {
      await dataSource.markAllAsRead();
      return unit;
    });
  }
}
