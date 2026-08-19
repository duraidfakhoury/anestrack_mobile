import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/list_lectures_usecase.dart';

abstract class LecturesEvent {}

class FetchLecturesEvent extends LecturesEvent {}

/// Re-fetches page 1, e.g. after pull-to-refresh.
class RefreshLecturesEvent extends LecturesEvent {}

/// Fetches the next page and appends it to the currently loaded list.
class LoadMoreLecturesEvent extends LecturesEvent {}

/// Filters lectures by a title/description substring, client-side.
class SearchLecturesEvent extends LecturesEvent {
  final String query;
  SearchLecturesEvent(this.query);
}

/// Clears an active search and restores the normal paginated list.
class ClearSearchEvent extends LecturesEvent {}

typedef LecturesState = BaseState<List<Lecture>>;

class LecturesBloc extends Bloc<LecturesEvent, LecturesState> {
  final ListLecturesUseCase listUseCase;
  final Logger _logger = Logger();

  static const _pageSize = 20;
  static const _searchPoolSize = 200;

  List<Lecture> _pagedItems = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<Lecture>? _searchCache;
  String _query = '';

  bool get hasMore => _query.isEmpty && _hasMore;

  LecturesBloc(this.listUseCase) : super(const BaseState<List<Lecture>>()) {
    on<FetchLecturesEvent>(_onFetch);
    on<RefreshLecturesEvent>(_onFetch);
    on<LoadMoreLecturesEvent>(_onLoadMore);
    on<SearchLecturesEvent>(_onSearch);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onFetch(
    LecturesEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(state.loading());
    final result = await listUseCase(limit: _pageSize, skip: 0);
    result.fold(
      (failure) => emit(state.error(failure)),
      (items) {
        _pagedItems = items;
        _hasMore = items.length == _pageSize;
        emit(state.successNotNull(_pagedItems));
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreLecturesEvent event,
    Emitter<LecturesState> emit,
  ) async {
    if (_query.isNotEmpty) return;
    if (_isLoadingMore || !_hasMore || !state.isSuccess) return;
    _isLoadingMore = true;

    final result = await listUseCase(limit: _pageSize, skip: _pagedItems.length);

    result.fold(
      (failure) => _logger.e('Failed to load more lectures: ${failure.message}'),
      (items) {
        _pagedItems = [..._pagedItems, ...items];
        _hasMore = items.length == _pageSize;
        emit(state.successNotNull(_pagedItems));
      },
    );

    _isLoadingMore = false;
  }

  Future<void> _onSearch(
    SearchLecturesEvent event,
    Emitter<LecturesState> emit,
  ) async {
    _query = event.query.trim();

    if (_query.isEmpty) {
      emit(state.successNotNull(_pagedItems));
      return;
    }

    if (_searchCache == null) {
      emit(state.loading());
      final result = await listUseCase(limit: _searchPoolSize, skip: 0);
      final failure = result.fold((f) => f, (_) => null);
      if (failure != null) {
        emit(state.error(failure));
        return;
      }
      _searchCache = result.fold((_) => const [], (items) => items);
    }

    final q = _query.toLowerCase();
    final filtered = _searchCache!
        .where(
          (lecture) =>
              lecture.title.toLowerCase().contains(q) ||
              lecture.description.toLowerCase().contains(q),
        )
        .toList();
    emit(state.successNotNull(filtered));
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<LecturesState> emit) {
    _query = '';
    emit(state.successNotNull(_pagedItems));
  }
}
