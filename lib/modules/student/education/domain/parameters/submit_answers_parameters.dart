import 'package:equatable/equatable.dart';

/// Parameters for `submitAnswers` (integration §10).
///
/// [answers] is positional: `answers[i]` is the chosen index for
/// `questions[i]`. A skipped question is `null` — the position is kept, never
/// shrink the list. A real JSON array is sent (preferred over a stringified
/// one).
class SubmitAnswersParameters extends Equatable {
  final String assessmentId;
  final List<int?> answers;

  const SubmitAnswersParameters({
    required this.assessmentId,
    required this.answers,
  });

  Map<String, dynamic> toJson() => {
    'assessmentId': assessmentId,
    'answers': answers,
  };

  @override
  List<Object?> get props => [assessmentId, answers];
}
