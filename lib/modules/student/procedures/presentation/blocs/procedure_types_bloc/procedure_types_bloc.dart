import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure_type.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_procedure_types_usecase.dart';
import 'package:logger/logger.dart';

part 'procedure_types_event.dart';
part 'procedure_types_state.dart';

class ProcedureTypesBloc
    extends Bloc<ProcedureTypesEvent, ProcedureTypesState> {
  final ListProcedureTypesUseCase listProcedureTypesUseCase;

  ProcedureTypesBloc(this.listProcedureTypesUseCase)
    : super(const BaseState<List<ProcedureType>>()) {
    on<FetchProcedureTypesEvent>(_onFetchProcedureTypes);
  }

  Future<void> _onFetchProcedureTypes(
    FetchProcedureTypesEvent event,
    Emitter<ProcedureTypesState> emit,
  ) async {
    emit(state.loading());
      final result = await listProcedureTypesUseCase();
      result.fold(
        (failure) {
          Logger().e('Failed to fetch procedure types: $failure');
          emit(state.error(failure));
        },
        (procedureTypes) {
          Logger().i(
            'Successfully fetched ${procedureTypes.length} procedure types',
          );
          emit(state.successNotNull(procedureTypes));
        },
      );
   
  }
}
