import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/home/domain/entities/student_dashboard.dart';
import 'package:anestrack_mobile/modules/student/home/domain/parameters/get_student_dashboard_parameters.dart';
import 'package:anestrack_mobile/modules/student/home/domain/usecases/get_student_dashboard_usecase.dart';

part 'student_dashboard_event.dart';
part 'student_dashboard_state.dart';

class StudentDashboardBloc
    extends Bloc<StudentDashboardEvent, StudentDashboardState> {
  final GetStudentDashboardUseCase getStudentDashboardUseCase;
  final Logger _logger = Logger();

  StudentDashboardBloc(this.getStudentDashboardUseCase)
    : super(const BaseState<StudentDashboardStats>()) {
    on<FetchStudentDashboardEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchStudentDashboardEvent event,
    Emitter<StudentDashboardState> emit,
  ) async {
    emit(state.loading());
    final result = await getStudentDashboardUseCase(
      const GetStudentDashboardParameters(),
    );
    result.fold(
      (failure) {
        _logger.e('Failed to fetch student dashboard: ${failure.message}');
        emit(state.error(failure));
      },
      (dashboard) {
        _logger.i('Fetched student dashboard');
        emit(state.successNotNull(dashboard));
      },
    );
  }
}
