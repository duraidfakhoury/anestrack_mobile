import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_question.dart';

class AssessmentQuestionModel extends AssessmentQuestion {
  const AssessmentQuestionModel({
    required super.question,
    required super.choices,
    required super.correctAnswerIndex,
  });

  factory AssessmentQuestionModel.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestionModel(
      question: json['question'] as String? ?? '',
      choices: (json['choices'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      correctAnswerIndex: (json['correctAnswerIndex'] as num?)?.toInt() ?? 0,
    );
  }
}
