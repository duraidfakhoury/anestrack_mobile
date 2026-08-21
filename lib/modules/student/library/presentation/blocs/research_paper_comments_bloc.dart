import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper_comment.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_comment_parameters.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/create_research_paper_comment_usecase.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/list_research_paper_comments_usecase.dart';

abstract class ResearchPaperCommentsEvent {}

class FetchResearchPaperCommentsEvent extends ResearchPaperCommentsEvent {
  final String paperId;
  FetchResearchPaperCommentsEvent(this.paperId);
}

class SubmitResearchPaperCommentEvent extends ResearchPaperCommentsEvent {
  final String paperId;
  final String content;
  SubmitResearchPaperCommentEvent({required this.paperId, required this.content});
}

typedef ResearchPaperCommentsState = BaseState<List<ResearchPaperComment>>;

/// Shared by both the student paper-detail screen (read-only) and the
/// supervisor review screen (read + add note).
class ResearchPaperCommentsBloc
    extends Bloc<ResearchPaperCommentsEvent, ResearchPaperCommentsState> {
  final ListResearchPaperCommentsUseCase listUseCase;
  final CreateResearchPaperCommentUseCase createUseCase;
  final Logger _logger = Logger();

  List<ResearchPaperComment> _items = [];

  ResearchPaperCommentsBloc(this.listUseCase, this.createUseCase)
    : super(const BaseState<List<ResearchPaperComment>>()) {
    on<FetchResearchPaperCommentsEvent>(_onFetch);
    on<SubmitResearchPaperCommentEvent>(_onSubmit);
  }

  Future<void> _onFetch(
    FetchResearchPaperCommentsEvent event,
    Emitter<ResearchPaperCommentsState> emit,
  ) async {
    emit(state.loading());
    final result = await listUseCase(event.paperId);
    result.fold(
      (failure) => emit(state.error(failure)),
      (items) {
        _items = items;
        emit(state.successNotNull(_items));
      },
    );
  }

  Future<void> _onSubmit(
    SubmitResearchPaperCommentEvent event,
    Emitter<ResearchPaperCommentsState> emit,
  ) async {
    final result = await createUseCase(
      CreateResearchPaperCommentParameters(
        paperId: event.paperId,
        content: event.content,
      ),
    );
    result.fold(
      (failure) {
        _logger.e('Failed to add research paper comment: ${failure.message}');
        emit(state.error(failure));
      },
      (comment) {
        _items = [comment, ..._items];
        emit(state.successNotNull(_items));
      },
    );
  }
}
