import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/queued_cosigned_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_queued_cosigned_procedures_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/queued_cosigned_procedures_bloc/queued_cosigned_procedures_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/queued_cosigned_procedures_bloc/queued_cosigned_procedures_state.dart';

class QueuedCosignedProceduresBloc
    extends Bloc<QueuedCosignedProceduresEvent, QueuedCosignedProceduresState> {
  final ListQueuedCosignedProceduresUseCase listQueuedCosignedProceduresUseCase;
  final Logger _logger = Logger();

  QueuedCosignedProceduresBloc(this.listQueuedCosignedProceduresUseCase)
    : super(const BaseState<List<QueuedCosignedProcedure>>()) {
    on<FetchQueuedCosignedProceduresEvent>(_onFetch);
    on<RefreshQueuedCosignedProceduresEvent>(_onFetch);
  }

  Future<void> _onFetch(
    QueuedCosignedProceduresEvent event,
    Emitter<QueuedCosignedProceduresState> emit,
  ) async {
    emit(state.loading());

    final result = await listQueuedCosignedProceduresUseCase();

    result.fold(
      (failure) {
        _logger.e(
          "Failed to fetch queued co-signed procedures: ${failure.message}",
        );
        emit(state.error(failure));
      },
      (items) {
        emit(state.successNotNull(items));
      },
    );
  }
}
