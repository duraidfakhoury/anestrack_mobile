import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_parameters.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/create_research_paper_usecase.dart';

abstract class PublishResearchEvent {}

class SubmitPublishResearchEvent extends PublishResearchEvent {
  final CreateResearchPaperParameters parameters;
  SubmitPublishResearchEvent(this.parameters);
}

class ResetPublishResearchEvent extends PublishResearchEvent {}

typedef PublishResearchState = BaseState<ResearchPaper>;

class PublishResearchBloc
    extends Bloc<PublishResearchEvent, PublishResearchState> {
  final CreateResearchPaperUseCase createResearchPaperUseCase;
  final Logger _logger = Logger();

  PublishResearchBloc(this.createResearchPaperUseCase)
    : super(const BaseState<ResearchPaper>()) {
    on<SubmitPublishResearchEvent>(_onSubmit);
    on<ResetPublishResearchEvent>(_onReset);
  }

  Future<void> _onSubmit(
    SubmitPublishResearchEvent event,
    Emitter<PublishResearchState> emit,
  ) async {
    emit(state.loading());
    final result = await createResearchPaperUseCase(event.parameters);
    result.fold(
      (failure) {
        _logger.e('Failed to publish research paper: ${failure.message}');
        emit(state.error(failure));
      },
      (paper) {
        _logger.i('Published research paper ${paper.id}');
        emit(state.successNotNull(paper));
      },
    );
  }

  void _onReset(
    ResetPublishResearchEvent event,
    Emitter<PublishResearchState> emit,
  ) {
    emit(const BaseState<ResearchPaper>());
  }
}
