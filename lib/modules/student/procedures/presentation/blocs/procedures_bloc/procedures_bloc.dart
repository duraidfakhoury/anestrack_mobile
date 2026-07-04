import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_procedures_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_state.dart';

class ProceduresBloc extends Bloc<ProceduresEvent, ProceduresState> {
  final ListProceduresUseCase listProceduresUseCase;
  final Logger _logger = Logger();

  List<Procedure> _allProcedures = [];
  String _currentFilter = 'all';

  ProceduresBloc(this.listProceduresUseCase)
    : super(const BaseState<List<Procedure>>()) {
    on<FetchProceduresEvent>(_onFetchProcedures);
    on<FilterProceduresByStatusEvent>(_onFilterByStatus);
  }

  Future<void> _onFetchProcedures(
    FetchProceduresEvent event,
    Emitter<ProceduresState> emit,
  ) async {
    emit(state.loading());

    final result = await listProceduresUseCase(event.parameters);

    result.fold(
      (failure) {
        _logger.e("Failed to fetch procedures: ${failure.message}");
        emit(state.error(failure));
      },
      (procedures) {
        _logger.i("Successfully fetched ${procedures.length} procedures");
        _allProcedures = procedures;
        _applyFilter(emit);
      },
    );
  }

  Future<void> _onFilterByStatus(
    FilterProceduresByStatusEvent event,
    Emitter<ProceduresState> emit,
  ) async {
    _currentFilter = event.status;
    _applyFilter(emit);
  }

  void _applyFilter(Emitter<ProceduresState> emit) {
    final filtered = _currentFilter == 'all'
        ? _allProcedures
        : _allProcedures
              .where((proc) => proc.status == _currentFilter)
              .toList();

    emit(state.successNotNull(filtered));
  }
}
