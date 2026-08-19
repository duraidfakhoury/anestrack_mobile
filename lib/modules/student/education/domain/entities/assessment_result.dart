import 'package:equatable/equatable.dart';

/// The graded outcome of a [LectureAssessment] submission (`StudentAnswer` Parse class).
class AssessmentResult extends Equatable {
  final String assessmentId;
  final List<int> answers;
  final double score;
  final int correctCount;

  const AssessmentResult({
    required this.assessmentId,
    required this.answers,
    this.score = 0,
    this.correctCount = 0,
  });

  @override
  List<Object?> get props => [assessmentId, answers, score, correctCount];
}
