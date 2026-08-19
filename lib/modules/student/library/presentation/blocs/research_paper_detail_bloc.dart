import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/get_research_paper_usecase.dart';

abstract class ResearchPaperDetailEvent {}

class FetchResearchPaperDetailEvent extends ResearchPaperDetailEvent {
  final String id;
  FetchResearchPaperDetailEvent(this.id);
}

typedef ResearchPaperDetailState = BaseState<ResearchPaper>;

class ResearchPaperDetailBloc
    extends Bloc<ResearchPaperDetailEvent, ResearchPaperDetailState> {
  final GetResearchPaperUseCase getResearchPaperUseCase;
  final Logger _logger = Logger();

  ResearchPaperDetailBloc(this.getResearchPaperUseCase)
    : super(const BaseState<ResearchPaper>()) {
    on<FetchResearchPaperDetailEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchResearchPaperDetailEvent event,
    Emitter<ResearchPaperDetailState> emit,
  ) async {
    emit(state.loading());
    final result = await getResearchPaperUseCase(event.id);
    result.fold((failure) => emit(state.error(failure)), (paper) {
      _logger.i('Fetched research paper ${event.id}');
      emit(state.successNotNull(paper));
    });
  }
}
