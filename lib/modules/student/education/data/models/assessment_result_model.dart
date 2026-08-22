import 'dart:convert';

import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_answer_breakdown.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_result.dart';

class AssessmentResultModel extends AssessmentResult {
  const AssessmentResultModel({
    required super.assessmentId,
    super.answers,
    super.score,
    super.correctCount,
    super.totalQuestions,
    super.answeredCount,
    super.percentage,
    super.breakdown,
    super.submissionId,
    super.submittedAt,
  });

  /// Parses both response shapes:
  /// - `submitAnswers`: top-level `score`/`correctCount`/`answers` plus a
  ///   nested `result` block (§10).
  /// - `getAssessmentResult`: flat `score`/`percentage`/`breakdown`/… (§11).
  factory AssessmentResultModel.fromJson(Map<String, dynamic> json) {
    // submitAnswers nests the summary under `result`; getAssessmentResult is
    // already flat. Merge so either shape reads uniformly.
    final result = json['result'];
    final summary = result is Map
        ? Map<String, dynamic>.from(result)
        : json;

    return AssessmentResultModel(
      assessmentId: _parseId(json['assessmentId'] ?? json['assessment']),
      answers: _parseAnswers(json['answers']),
      score: (summary['score'] as num?)?.toDouble() ??
          (json['score'] as num?)?.toDouble() ??
          0,
      correctCount: (summary['correctCount'] as num?)?.toInt() ??
          (json['correctCount'] as num?)?.toInt() ??
          0,
      totalQuestions: (summary['totalQuestions'] as num?)?.toInt() ?? 0,
      answeredCount: (summary['answeredCount'] as num?)?.toInt() ?? 0,
      percentage: (summary['percentage'] as num?)?.toDouble() ??
          (json['percentage'] as num?)?.toDouble() ??
          0,
      breakdown: _parseBreakdown(json['breakdown']),
      submissionId:
          (json['submissionId'] ?? json['id'] ?? json['objectId'])?.toString(),
      submittedAt: _parseDate(json['submittedAt']),
    );
  }

  static String _parseId(dynamic value) {
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
    // A blank comes back as -1; keep the position.
    return list.map((e) => e == null ? -1 : (e as num).toInt()).toList();
  }

  static List<AssessmentAnswerBreakdown> _parseBreakdown(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((e) =>
            AssessmentAnswerBreakdown.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static String? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map && value['iso'] != null) return value['iso'] as String;
    return null;
  }
}
