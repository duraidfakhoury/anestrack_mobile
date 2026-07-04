import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/supervisor.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_supervisors_usecase.dart';

part 'supervisors_event.dart';
part 'supervisors_state.dart';

class SupervisorsBloc extends Bloc<SupervisorsEvent, SupervisorsState> {
  final ListSupervisorsUseCase listSupervisorsUseCase;
  final Logger _logger = Logger();

  SupervisorsBloc(this.listSupervisorsUseCase)
    : super(const BaseState<List<Supervisor>>()) {
    on<FetchSupervisorsEvent>(_onFetchSupervisors);
  }

  Future<void> _onFetchSupervisors(
    FetchSupervisorsEvent event,
    Emitter<SupervisorsState> emit,
  ) async {
    emit(state.loading());
    final result = await listSupervisorsUseCase();
    result.fold(
      (failure) {
        _logger.e('Failed to fetch supervisors: ${failure.message}');
        emit(state.error(failure));
      },
      (supervisors) {
        _logger.i('Fetched ${supervisors.length} supervisors');
        emit(state.successNotNull(supervisors));
      },
    );
  }
}
