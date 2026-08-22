import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/create_lecture_evaluation_parameters.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/create_lecture_evaluation_usecase.dart';

abstract class LectureEvaluationEvent {}

class SubmitLectureRatingEvent extends LectureEvaluationEvent {
  final String lectureId;
  final int rating;
  final String? feedback;
  SubmitLectureRatingEvent({
    required this.lectureId,
    required this.rating,
    this.feedback,
  });
}

typedef LectureEvaluationState = BaseState<bool>;

class LectureEvaluationBloc
    extends Bloc<LectureEvaluationEvent, LectureEvaluationState> {
  final CreateLectureEvaluationUseCase createEvaluationUseCase;

  LectureEvaluationBloc(this.createEvaluationUseCase)
    : super(const BaseState<bool>()) {
    on<SubmitLectureRatingEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitLectureRatingEvent event,
    Emitter<LectureEvaluationState> emit,
  ) async {
    emit(state.loading());
    final result = await createEvaluationUseCase(
      CreateLectureEvaluationParameters(
        lectureId: event.lectureId,
        rating: event.rating,
        feedback: event.feedback,
      ),
    );
    result.fold(
      (failure) => emit(state.error(failure)),
      (_) => emit(state.successNotNull(true)),
    );
  }
}
