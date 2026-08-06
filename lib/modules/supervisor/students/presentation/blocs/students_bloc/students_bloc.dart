import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/entities/student.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/parameters/list_students_parameters.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/usecases/list_students_usecase.dart';

part 'students_event.dart';
part 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final ListStudentsUseCase listStudentsUseCase;
  final Logger _logger = Logger();

  StudentsBloc(this.listStudentsUseCase)
    : super(const BaseState<List<Student>>()) {
    on<FetchStudentsEvent>(_onFetchStudents);
  }

  Future<void> _onFetchStudents(
    FetchStudentsEvent event,
    Emitter<StudentsState> emit,
  ) async {
    emit(state.loading());
    final result = await listStudentsUseCase(event.parameters);
    result.fold(
      (failure) {
        _logger.e('Failed to fetch students: ${failure.message}');
        emit(state.error(failure));
      },
      (students) {
        _logger.i('Fetched ${students.length} students');
        emit(state.successNotNull(students));
      },
    );
  }
}
