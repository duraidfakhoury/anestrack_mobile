import 'dart:convert';

import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_result.dart';

class AssessmentResultModel extends AssessmentResult {
  const AssessmentResultModel({
    required super.assessmentId,
    required super.answers,
    super.score,
    super.correctCount,
  });

  factory AssessmentResultModel.fromJson(Map<String, dynamic> json) {
    return AssessmentResultModel(
      assessmentId: _parseAssessmentId(json['assessmentId'] ?? json['assessment']),
      answers: _parseAnswers(json['answers']),
      score: (json['score'] as num?)?.toDouble() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
    );
  }

  static String _parseAssessmentId(dynamic value) {
    if (value is String) return value;
    if (value is Map) {
      return (value['id'] ?? value['objectId'])?.toString() ?? '';
    }
    return '';
  }

  static List<int> _parseAnswers(dynamic value) {
    var list = value;
    if (list is String) {
      try {
        list = jsonDecode(list);
      } catch (_) {
        return const [];
      }
    }
    if (list is! List) return const [];
    return list.map((e) => (e as num).toInt()).toList();
  }
}
