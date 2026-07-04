import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/co_sign_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/co_sign_procedure_usecase.dart';

abstract class CoSignActionEvent {}

class SubmitCoSignEvent extends CoSignActionEvent {
  final CoSignParameters parameters;
  SubmitCoSignEvent(this.parameters);
}

class ResetCoSignActionEvent extends CoSignActionEvent {}

typedef CoSignActionState = BaseState<Procedure>;

/// Supervisor — perform the co-sign (Flow 1) once the code is in hand.
class CoSignActionBloc extends Bloc<CoSignActionEvent, CoSignActionState> {
  final CoSignProcedureUseCase useCase;
  final Logger _logger = Logger();

  CoSignActionBloc(this.useCase) : super(const BaseState<Procedure>()) {
    on<SubmitCoSignEvent>(_onSubmit);
    on<ResetCoSignActionEvent>((_, emit) => emit(const BaseState<Procedure>()));
  }

  Future<void> _onSubmit(
    SubmitCoSignEvent event,
    Emitter<CoSignActionState> emit,
  ) async {
    emit(state.loading());
    final result = await useCase(event.parameters);
    result.fold(
      (failure) {
        _logger.e('Failed to co-sign: ${failure.message}');
        emit(state.error(failure));
      },
      (procedure) => emit(state.successNotNull(procedure)),
    );
  }
}
