import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_assessment.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/get_lecture_assessment_usecase.dart';

abstract class LectureAssessmentEvent {}

class FetchAssessmentEvent extends LectureAssessmentEvent {
  final String lectureId;
  FetchAssessmentEvent(this.lectureId);
}

/// [data] is `null` on success when the lecture has no assessment yet —
/// distinct from [BaseState.isError].
typedef LectureAssessmentState = BaseState<LectureAssessment?>;

class LectureAssessmentBloc
    extends Bloc<LectureAssessmentEvent, LectureAssessmentState> {
  final GetLectureAssessmentUseCase getLectureAssessmentUseCase;

  LectureAssessmentBloc(this.getLectureAssessmentUseCase)
    : super(const BaseState<LectureAssessment?>()) {
    on<FetchAssessmentEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchAssessmentEvent event,
    Emitter<LectureAssessmentState> emit,
  ) async {
    emit(state.loading());
    final result = await getLectureAssessmentUseCase(event.lectureId);
    result.fold(
      (failure) => emit(state.error(failure)),
      (assessment) => emit(state.success(assessment)),
    );
  }
}
