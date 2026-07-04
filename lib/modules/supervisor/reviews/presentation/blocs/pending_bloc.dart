import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_pending_for_supervisor_usecase.dart';

abstract class PendingEvent {}

class FetchPendingEvent extends PendingEvent {}

typedef PendingState = BaseState<List<Procedure>>;

/// Supervisor — everything awaiting this supervisor: open live co-signs and
/// pending async confirmations (Flow 2/3).
class PendingBloc extends Bloc<PendingEvent, PendingState> {
  final ListPendingForSupervisorUseCase useCase;
  final Logger _logger = Logger();

  PendingBloc(this.useCase) : super(const BaseState<List<Procedure>>()) {
    on<FetchPendingEvent>(_onFetch);
  }

  Future<void> _onFetch(FetchPendingEvent event, Emitter<PendingState> emit) async {
    emit(state.loading());
    final result = await useCase();
    result.fold(
      (failure) {
        _logger.e('Failed to fetch pending: ${failure.message}');
        emit(state.error(failure));
      },
      (procedures) {
        _logger.i('Fetched ${procedures.length} pending procedures');
        emit(state.successNotNull(procedures));
      },
    );
  }
}
