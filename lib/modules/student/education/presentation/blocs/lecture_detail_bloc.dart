import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/get_lecture_usecase.dart';

abstract class LectureDetailEvent {}

class FetchLectureDetailEvent extends LectureDetailEvent {
  final String id;
  FetchLectureDetailEvent(this.id);
}

typedef LectureDetailState = BaseState<Lecture>;

class LectureDetailBloc extends Bloc<LectureDetailEvent, LectureDetailState> {
  final GetLectureUseCase getLectureUseCase;

  LectureDetailBloc(this.getLectureUseCase)
    : super(const BaseState<Lecture>()) {
    on<FetchLectureDetailEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchLectureDetailEvent event,
    Emitter<LectureDetailState> emit,
  ) async {
    emit(state.loading());
    final result = await getLectureUseCase(event.id);
    result.fold(
      (failure) => emit(state.error(failure)),
      (lecture) => emit(state.successNotNull(lecture)),
    );
  }
}
