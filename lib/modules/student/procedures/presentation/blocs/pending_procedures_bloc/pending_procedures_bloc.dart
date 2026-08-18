import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/pending_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_pending_procedures_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/pending_procedures_bloc/pending_procedures_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/pending_procedures_bloc/pending_procedures_state.dart';

class PendingProceduresBloc
    extends Bloc<PendingProceduresEvent, PendingProceduresState> {
  final ListPendingProceduresUseCase listPendingProceduresUseCase;
  final Logger _logger = Logger();

  PendingProceduresBloc(this.listPendingProceduresUseCase)
    : super(const BaseState<List<PendingProcedure>>()) {
    on<FetchPendingProceduresEvent>(_onFetch);
    on<RefreshPendingProceduresEvent>(_onFetch);
  }

  Future<void> _onFetch(
    PendingProceduresEvent event,
    Emitter<PendingProceduresState> emit,
  ) async {
    emit(state.loading());

    final result = await listPendingProceduresUseCase();

    result.fold(
      (failure) {
        _logger.e("Failed to fetch pending procedures: ${failure.message}");
        emit(state.error(failure));
      },
      (items) {
        emit(state.successNotNull(items));
      },
    );
  }
}
