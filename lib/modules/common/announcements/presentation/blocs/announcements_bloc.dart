import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/entities/announcement.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/usecases/list_announcements_usecase.dart';

abstract class AnnouncementsEvent {}

class FetchAnnouncementsEvent extends AnnouncementsEvent {}

/// Re-fetches page 1, e.g. after pull-to-refresh.
class RefreshAnnouncementsEvent extends AnnouncementsEvent {}

/// Fetches the next page and appends it to the currently loaded list.
class LoadMoreAnnouncementsEvent extends AnnouncementsEvent {}

typedef AnnouncementsState = BaseState<List<Announcement>>;

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  final ListAnnouncementsUseCase listUseCase;
  final Logger _logger = Logger();

  static const _pageSize = 20;

  List<Announcement> _allItems = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;

  AnnouncementsBloc(this.listUseCase)
    : super(const BaseState<List<Announcement>>()) {
    on<FetchAnnouncementsEvent>(_onFetch);
    on<RefreshAnnouncementsEvent>(_onFetch);
    on<LoadMoreAnnouncementsEvent>(_onLoadMore);
  }

  Future<void> _onFetch(
    AnnouncementsEvent event,
    Emitter<AnnouncementsState> emit,
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
    LoadMoreAnnouncementsEvent event,
    Emitter<AnnouncementsState> emit,
  ) async {
    if (_isLoadingMore || !_hasMore || !state.isSuccess) return;
    _isLoadingMore = true;

    final result = await listUseCase(limit: _pageSize, skip: _allItems.length);

    result.fold(
      (failure) => _logger.e('Failed to load more announcements: ${failure.message}'),
      (items) {
        _allItems = [..._allItems, ...items];
        _hasMore = items.length == _pageSize;
        emit(state.successNotNull(_allItems));
      },
    );

    _isLoadingMore = false;
  }
}
