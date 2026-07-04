import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/confirm_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/confirm_procedure_usecase.dart';

abstract class ConfirmActionEvent {}

class SubmitConfirmEvent extends ConfirmActionEvent {
  final ConfirmProcedureParameters parameters;
  SubmitConfirmEvent(this.parameters);
}

class ResetConfirmActionEvent extends ConfirmActionEvent {}

typedef ConfirmActionState = BaseState<Procedure>;

/// Supervisor — confirm or reject an async procedure (Flow 2/3).
class ConfirmActionBloc extends Bloc<ConfirmActionEvent, ConfirmActionState> {
  final ConfirmProcedureUseCase useCase;
  final Logger _logger = Logger();

  ConfirmActionBloc(this.useCase) : super(const BaseState<Procedure>()) {
    on<SubmitConfirmEvent>(_onSubmit);
    on<ResetConfirmActionEvent>((_, emit) => emit(const BaseState<Procedure>()));
  }

  Future<void> _onSubmit(
    SubmitConfirmEvent event,
    Emitter<ConfirmActionState> emit,
  ) async {
    emit(state.loading());
    final result = await useCase(event.parameters);
    result.fold(
      (failure) {
        _logger.e('Failed to confirm/reject: ${failure.message}');
        emit(state.error(failure));
      },
      (procedure) => emit(state.successNotNull(procedure)),
    );
  }
}
