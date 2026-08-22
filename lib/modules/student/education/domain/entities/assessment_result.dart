import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_answer_breakdown.dart';

/// The graded outcome of a [LectureAssessment] submission (`StudentAnswer`
/// Parse class). Populated from either `submitAnswers` (§10) or
/// `getAssessmentResult` (§11) — both feed the same score summary; only the
/// review call carries the per-question [breakdown].
class AssessmentResult extends Equatable {
  final String assessmentId;

  /// Stored answers; `-1` means the question was left blank.
  final List<int> answers;
  final double score;
  final int correctCount;
  final int totalQuestions;
  final int answeredCount;

  /// 0–100.
  final double percentage;
  final List<AssessmentAnswerBreakdown> breakdown;
  final String? submissionId;
  final String? submittedAt;

  const AssessmentResult({
    required this.assessmentId,
    this.answers = const [],
    this.score = 0,
    this.correctCount = 0,
    this.totalQuestions = 0,
    this.answeredCount = 0,
    this.percentage = 0,
    this.breakdown = const [],
    this.submissionId,
    this.submittedAt,
  });

  @override
  List<Object?> get props => [
    assessmentId,
    answers,
    score,
    correctCount,
    totalQuestions,
    answeredCount,
    percentage,
    breakdown,
    submissionId,
    submittedAt,
  ];
}
