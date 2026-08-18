import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/entities/app_notification.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/usecases/notification_usecases.dart';

abstract class NotificationsEvent {}

class FetchNotificationsEvent extends NotificationsEvent {}

/// Re-fetches page 1, e.g. after pull-to-refresh.
class RefreshNotificationsEvent extends NotificationsEvent {}

/// Fetches the next page and appends it to the currently loaded list.
class LoadMoreNotificationsEvent extends NotificationsEvent {}

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

  static const _pageSize = 20;

  List<AppNotification> _allItems = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;

  NotificationsBloc(
    this.listUseCase,
    this.markReadUseCase,
    this.markAllReadUseCase,
  ) : super(const BaseState<List<AppNotification>>()) {
    on<FetchNotificationsEvent>(_onFetch);
    on<RefreshNotificationsEvent>(_onFetch);
    on<LoadMoreNotificationsEvent>(_onLoadMore);
    on<MarkNotificationReadEvent>(_onMarkOne);
    on<MarkAllNotificationsReadEvent>(_onMarkAll);
  }

  Future<void> _onFetch(
    NotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.loading());
    final result = await listUseCase(limit: _pageSize, skip: 0);
    result.fold(
      (failure) => emit(state.error(failure)),
      (items) {
        _allItems = items;
        _hasMore = items.length == _pageSize;
        emit(state.successNotNull(_allItems));
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (_isLoadingMore || !_hasMore || !state.isSuccess) return;
    _isLoadingMore = true;

    final result = await listUseCase(limit: _pageSize, skip: _allItems.length);

    result.fold(
      (failure) => _logger.e('Failed to load more notifications: ${failure.message}'),
      (items) {
        _allItems = [..._allItems, ...items];
        _hasMore = items.length == _pageSize;
        emit(state.successNotNull(_allItems));
      },
    );

    _isLoadingMore = false;
  }

  Future<void> _onMarkOne(
    MarkNotificationReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    // Optimistic local update.
    _allItems = [
      for (final n in _allItems)
        n.id == event.id ? n.copyWith(isRead: true) : n,
    ];
    emit(state.successNotNull(_allItems));
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
    _allItems = [for (final n in _allItems) n.copyWith(isRead: true)];
    emit(state.successNotNull(_allItems));
    final result = await markAllReadUseCase();
    result.fold(
      (failure) => _logger.e('markAllAsRead failed: ${failure.message}'),
      (_) {},
    );
  }
}
