import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_result.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/submit_answers_parameters.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/submit_answers_usecase.dart';

abstract class AssessmentResultEvent {}

class SubmitAnswersEvent extends AssessmentResultEvent {
  final String assessmentId;

  /// Positional answers; `null` marks a skipped question (integration §10).
  final List<int?> answers;
  SubmitAnswersEvent({required this.assessmentId, required this.answers});
}

typedef AssessmentResultState = BaseState<AssessmentResult>;

class AssessmentResultBloc
    extends Bloc<AssessmentResultEvent, AssessmentResultState> {
  final SubmitAnswersUseCase submitAnswersUseCase;

  AssessmentResultBloc(this.submitAnswersUseCase)
    : super(const BaseState<AssessmentResult>()) {
    on<SubmitAnswersEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitAnswersEvent event,
    Emitter<AssessmentResultState> emit,
  ) async {
    emit(state.loading());
    final result = await submitAnswersUseCase(
      SubmitAnswersParameters(
        assessmentId: event.assessmentId,
        answers: event.answers,
      ),
    );
    result.fold(
      (failure) => emit(state.error(failure)),
      (assessmentResult) => emit(state.successNotNull(assessmentResult)),
    );
  }
}
