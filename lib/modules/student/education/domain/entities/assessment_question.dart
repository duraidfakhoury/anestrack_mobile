import 'package:equatable/equatable.dart';

/// A single question within a [LectureAssessment].
class AssessmentQuestion extends Equatable {
  final String question;
  final List<String> choices;
  final int correctAnswerIndex;

  const AssessmentQuestion({
    required this.question,
    required this.choices,
    required this.correctAnswerIndex,
  });

  @override
  List<Object?> get props => [question, choices, correctAnswerIndex];
}
