import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/evaluation_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/create_evaluation_usecase.dart';

abstract class EvaluationActionEvent {}

class SubmitEvaluationEvent extends EvaluationActionEvent {
  final EvaluationParameters parameters;
  SubmitEvaluationEvent(this.parameters);
}

typedef EvaluationActionState = BaseState<bool>;

/// Supervisor — rate the student's performance on a procedure, ahead of a
/// co-sign or confirm action.
class EvaluationActionBloc
    extends Bloc<EvaluationActionEvent, EvaluationActionState> {
  final CreateEvaluationUseCase useCase;
  final Logger _logger = Logger();

  EvaluationActionBloc(this.useCase) : super(const BaseState<bool>()) {
    on<SubmitEvaluationEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitEvaluationEvent event,
    Emitter<EvaluationActionState> emit,
  ) async {
    emit(state.loading());
    final result = await useCase(event.parameters);
    result.fold(
      (failure) {
        _logger.e('Failed to create evaluation: ${failure.message}');
        emit(state.error(failure));
      },
      (success) => emit(state.successNotNull(success)),
    );
  }
}
