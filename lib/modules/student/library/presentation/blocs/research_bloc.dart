import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/list_research_papers_usecase.dart';

abstract class ResearchEvent {}

class FetchResearchPapersEvent extends ResearchEvent {}

/// Re-fetches page 1, e.g. after pull-to-refresh.
class RefreshResearchPapersEvent extends ResearchEvent {}

/// Fetches the next page and appends it to the currently loaded list.
class LoadMoreResearchPapersEvent extends ResearchEvent {}

typedef ResearchState = BaseState<List<ResearchPaper>>;

class ResearchBloc extends Bloc<ResearchEvent, ResearchState> {
  final ListResearchPapersUseCase listUseCase;
  final Logger _logger = Logger();

  static const _pageSize = 20;

  List<ResearchPaper> _allItems = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;

  ResearchBloc(this.listUseCase)
    : super(const BaseState<List<ResearchPaper>>()) {
    on<FetchResearchPapersEvent>(_onFetch);
    on<RefreshResearchPapersEvent>(_onFetch);
    on<LoadMoreResearchPapersEvent>(_onLoadMore);
  }

  Future<void> _onFetch(
    ResearchEvent event,
    Emitter<ResearchState> emit,
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
    LoadMoreResearchPapersEvent event,
    Emitter<ResearchState> emit,
  ) async {
    if (_isLoadingMore || !_hasMore || !state.isSuccess) return;
    _isLoadingMore = true;

    final result = await listUseCase(limit: _pageSize, skip: _allItems.length);

    result.fold(
      (failure) => _logger.e('Failed to load more research papers: ${failure.message}'),
      (items) {
        _allItems = [..._allItems, ...items];
        _hasMore = items.length == _pageSize;
        emit(state.successNotNull(_allItems));
      },
    );

    _isLoadingMore = false;
  }
}
