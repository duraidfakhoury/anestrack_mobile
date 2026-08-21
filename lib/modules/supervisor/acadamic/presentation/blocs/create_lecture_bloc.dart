import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/create_lecture_parameters.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/create_lecture_usecase.dart';

abstract class CreateLectureEvent {}

class SubmitCreateLectureEvent extends CreateLectureEvent {
  final CreateLectureParameters parameters;
  SubmitCreateLectureEvent(this.parameters);
}

typedef CreateLectureState = BaseState<Lecture>;

class CreateLectureBloc extends Bloc<CreateLectureEvent, CreateLectureState> {
  final CreateLectureUseCase createLectureUseCase;
  final Logger _logger = Logger();

  CreateLectureBloc(this.createLectureUseCase)
    : super(const BaseState<Lecture>()) {
    on<SubmitCreateLectureEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitCreateLectureEvent event,
    Emitter<CreateLectureState> emit,
  ) async {
    emit(state.loading());
    final result = await createLectureUseCase(event.parameters);
    result.fold(
      (failure) {
        _logger.e('Failed to create lecture: ${failure.message}');
        emit(state.error(failure));
      },
      (lecture) {
        _logger.i('Created lecture ${lecture.id}');
        emit(state.successNotNull(lecture));
      },
    );
  }
}
