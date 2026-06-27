import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/create_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_state.dart';

class CreateProcedureBloc
    extends Bloc<CreateProcedureEvent, CreateProcedureState> {
  final CreateProcedureUseCase createProcedureUseCase;
  final Logger _logger = Logger();

  CreateProcedureBloc(this.createProcedureUseCase)
    : super(const BaseState<bool>()) {
    on<SubmitCreateProcedureEvent>(_onSubmitCreateProcedure);
    on<ResetCreateProcedureEvent>(_onResetCreateProcedure);
  }

  Future<void> _onSubmitCreateProcedure(
    SubmitCreateProcedureEvent event,
    Emitter<CreateProcedureState> emit,
  ) async {
    emit(state.loading());

    final result = await createProcedureUseCase(event.parameters);

    result.fold(
      (failure) {
        _logger.e("Failed to create procedure: ${failure.message}");
        emit(state.error(failure));
      },
      (success) {
        _logger.i("Procedure created successfully");
        emit(state.successNotNull(success));
      },
    );
  }

  Future<void> _onResetCreateProcedure(
    ResetCreateProcedureEvent event,
    Emitter<CreateProcedureState> emit,
  ) async {
    emit(const BaseState<bool>());
  }
}
