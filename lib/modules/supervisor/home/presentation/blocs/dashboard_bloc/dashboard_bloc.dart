import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/entities/supervisor_dashboard.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/parameters/get_supervisor_dashboard_parameters.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/usecases/get_supervisor_dashboard_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetSupervisorDashboardUseCase getSupervisorDashboardUseCase;
  final Logger _logger = Logger();

  DashboardBloc(this.getSupervisorDashboardUseCase)
    : super(const BaseState<SupervisorDashboardStats>()) {
    on<FetchDashboardEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.loading());
    final result = await getSupervisorDashboardUseCase(
      GetSupervisorDashboardParameters(hospitalId: event.hospitalId),
    );
    result.fold(
      (failure) {
        _logger.e('Failed to fetch supervisor dashboard: ${failure.message}');
        emit(state.error(failure));
      },
      (dashboard) {
        _logger.i('Fetched supervisor dashboard');
        emit(state.successNotNull(dashboard));
      },
    );
  }
}
