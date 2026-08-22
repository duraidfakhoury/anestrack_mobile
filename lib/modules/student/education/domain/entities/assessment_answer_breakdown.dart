import 'package:equatable/equatable.dart';

/// One graded question in a submission review (`breakdown[i]` from
/// `getAssessmentResult`, integration §11).
class AssessmentAnswerBreakdown extends Equatable {
  final int index;
  final String question;

  /// The choice the student picked, or `null` when the question was left
  /// blank — render as "unanswered", not as choice 0.
  final int? selectedIndex;
  final int correctAnswerIndex;
  final bool isCorrect;

  const AssessmentAnswerBreakdown({
    required this.index,
    required this.question,
    required this.selectedIndex,
    required this.correctAnswerIndex,
    required this.isCorrect,
  });

  factory AssessmentAnswerBreakdown.fromJson(Map<String, dynamic> json) {
    final selected = json['selectedIndex'];
    return AssessmentAnswerBreakdown(
      index: (json['index'] as num?)?.toInt() ?? 0,
      question: json['question'] as String? ?? '',
      selectedIndex: selected == null ? null : (selected as num).toInt(),
      correctAnswerIndex: (json['correctAnswerIndex'] as num?)?.toInt() ?? 0,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
    index,
    question,
    selectedIndex,
    correctAnswerIndex,
    isCorrect,
  ];
}
