import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_assessment.dart';

/// Carries the assessment to the result screen via `GoRouterState.extra`. The
/// graded review (score + per-question breakdown) is fetched fresh there with
/// `getAssessmentResult` (integration §11) — not an entity, purely navigation
/// payload.
class QuizResultArgs extends Equatable {
  final LectureAssessment assessment;

  const QuizResultArgs({required this.assessment});

  @override
  List<Object?> get props => [assessment];
}
