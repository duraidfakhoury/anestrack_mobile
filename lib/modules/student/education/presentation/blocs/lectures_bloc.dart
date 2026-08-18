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

typedef LecturesState = BaseState<List<Lecture>>;

class LecturesBloc extends Bloc<LecturesEvent, LecturesState> {
  final ListLecturesUseCase listUseCase;
  final Logger _logger = Logger();

  static const _pageSize = 20;

  List<Lecture> _allItems = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;

  LecturesBloc(this.listUseCase) : super(const BaseState<List<Lecture>>()) {
    on<FetchLecturesEvent>(_onFetch);
    on<RefreshLecturesEvent>(_onFetch);
    on<LoadMoreLecturesEvent>(_onLoadMore);
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
        _allItems = items;
        _hasMore = items.length == _pageSize;
        emit(state.successNotNull(_allItems));
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreLecturesEvent event,
    Emitter<LecturesState> emit,
  ) async {
    if (_isLoadingMore || !_hasMore || !state.isSuccess) return;
    _isLoadingMore = true;

    final result = await listUseCase(limit: _pageSize, skip: _allItems.length);

    result.fold(
      (failure) => _logger.e('Failed to load more lectures: ${failure.message}'),
      (items) {
        _allItems = [..._allItems, ...items];
        _hasMore = items.length == _pageSize;
        emit(state.successNotNull(_allItems));
      },
    );

    _isLoadingMore = false;
  }
}
