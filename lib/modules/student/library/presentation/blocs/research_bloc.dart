import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/list_research_papers_usecase.dart';

abstract class ResearchEvent {}

class FetchResearchPapersEvent extends ResearchEvent {}

typedef ResearchState = BaseState<List<ResearchPaper>>;

class ResearchBloc extends Bloc<ResearchEvent, ResearchState> {
  final ListResearchPapersUseCase listUseCase;

  ResearchBloc(this.listUseCase)
    : super(const BaseState<List<ResearchPaper>>()) {
    on<FetchResearchPapersEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchResearchPapersEvent event,
    Emitter<ResearchState> emit,
  ) async {
    emit(state.loading());
    final result = await listUseCase();
    result.fold(
      (failure) => emit(state.error(failure)),
      (items) => emit(state.successNotNull(items)),
    );
  }
}
