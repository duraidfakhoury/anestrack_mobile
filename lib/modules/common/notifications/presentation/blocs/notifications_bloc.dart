import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/entities/app_notification.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/usecases/notification_usecases.dart';

abstract class NotificationsEvent {}

class FetchNotificationsEvent extends NotificationsEvent {}

class MarkNotificationReadEvent extends NotificationsEvent {
  final String id;
  MarkNotificationReadEvent(this.id);
}

class MarkAllNotificationsReadEvent extends NotificationsEvent {}

typedef NotificationsState = BaseState<List<AppNotification>>;

/// Loads the current user's notifications and handles mark-as-read actions.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final ListNotificationsUseCase listUseCase;
  final MarkNotificationReadUseCase markReadUseCase;
  final MarkAllNotificationsReadUseCase markAllReadUseCase;
  final Logger _logger = Logger();

  NotificationsBloc(
    this.listUseCase,
    this.markReadUseCase,
    this.markAllReadUseCase,
  ) : super(const BaseState<List<AppNotification>>()) {
    on<FetchNotificationsEvent>(_onFetch);
    on<MarkNotificationReadEvent>(_onMarkOne);
    on<MarkAllNotificationsReadEvent>(_onMarkAll);
  }

  Future<void> _onFetch(
    FetchNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.loading());
    final result = await listUseCase();
    result.fold(
      (failure) => emit(state.error(failure)),
      (items) => emit(state.successNotNull(items)),
    );
  }

  Future<void> _onMarkOne(
    MarkNotificationReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state.data ?? const [];
    // Optimistic local update.
    emit(
      state.successNotNull([
        for (final n in current)
          n.id == event.id ? n.copyWith(isRead: true) : n,
      ]),
    );
    final result = await markReadUseCase(event.id);
    result.fold(
      (failure) => _logger.e('markAsRead failed: ${failure.message}'),
      (_) {},
    );
  }

  Future<void> _onMarkAll(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state.data ?? const [];
    emit(
      state.successNotNull([for (final n in current) n.copyWith(isRead: true)]),
    );
    final result = await markAllReadUseCase();
    result.fold(
      (failure) => _logger.e('markAllAsRead failed: ${failure.message}'),
      (_) {},
    );
  }
}
