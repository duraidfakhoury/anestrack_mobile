import 'dart:convert';

import 'package:equatable/equatable.dart';

class SubmitAnswersParameters extends Equatable {
  final String assessmentId;
  final List<int> answers;

  const SubmitAnswersParameters({
    required this.assessmentId,
    required this.answers,
  });

  Map<String, dynamic> toJson() => {
    'assessmentId': assessmentId,
    'answers': jsonEncode(answers),
  };

  @override
  List<Object?> get props => [assessmentId, answers];
}
