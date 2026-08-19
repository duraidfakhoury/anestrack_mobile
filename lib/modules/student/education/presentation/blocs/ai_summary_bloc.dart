import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/ai_summary.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/generate_ai_summary_parameters.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/generate_ai_summary_usecase.dart';

abstract class AiSummaryEvent {}

class GenerateAiSummaryEvent extends AiSummaryEvent {
  final String lectureId;
  final bool regenerate;
  GenerateAiSummaryEvent({required this.lectureId, this.regenerate = false});
}

typedef AiSummaryState = BaseState<AiSummary>;

class AiSummaryBloc extends Bloc<AiSummaryEvent, AiSummaryState> {
  final GenerateAiSummaryUseCase generateAiSummaryUseCase;

  AiSummaryBloc(this.generateAiSummaryUseCase)
    : super(const BaseState<AiSummary>()) {
    on<GenerateAiSummaryEvent>(_onGenerate);
  }

  Future<void> _onGenerate(
    GenerateAiSummaryEvent event,
    Emitter<AiSummaryState> emit,
  ) async {
    emit(state.loading());
    final result = await generateAiSummaryUseCase(
      GenerateAiSummaryParameters(
        lectureId: event.lectureId,
        regenerate: event.regenerate,
      ),
    );
    result.fold(
      (failure) => emit(state.error(failure)),
      (summary) => emit(state.successNotNull(summary)),
    );
  }
}
