import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_result.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/get_assessment_result_usecase.dart';

abstract class AssessmentReviewEvent {}

class FetchAssessmentResultEvent extends AssessmentReviewEvent {
  final String assessmentId;
  final String? studentId;
  FetchAssessmentResultEvent({required this.assessmentId, this.studentId});
}

/// [data] is `null` on success when the student has not submitted yet —
/// distinct from [BaseState.isError] (integration §11).
typedef AssessmentReviewState = BaseState<AssessmentResult?>;

class AssessmentReviewBloc
    extends Bloc<AssessmentReviewEvent, AssessmentReviewState> {
  final GetAssessmentResultUseCase getAssessmentResultUseCase;

  AssessmentReviewBloc(this.getAssessmentResultUseCase)
    : super(const BaseState<AssessmentResult?>()) {
    on<FetchAssessmentResultEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchAssessmentResultEvent event,
    Emitter<AssessmentReviewState> emit,
  ) async {
    emit(state.loading());
    final result = await getAssessmentResultUseCase(
      assessmentId: event.assessmentId,
      studentId: event.studentId,
    );
    result.fold(
      (failure) => emit(state.error(failure)),
      (review) => emit(state.success(review)),
    );
  }
}
