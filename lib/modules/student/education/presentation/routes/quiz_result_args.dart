import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_result.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_assessment.dart';

/// Carries the just-graded quiz outcome via `GoRouterState.extra` to the
/// result screen — not an entity, purely navigation payload.
class QuizResultArgs extends Equatable {
  final LectureAssessment assessment;
  final AssessmentResult result;

  const QuizResultArgs({required this.assessment, required this.result});

  @override
  List<Object?> get props => [assessment, result];
}
