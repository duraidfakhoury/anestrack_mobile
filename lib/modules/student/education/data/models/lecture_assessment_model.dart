import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:anestrack_mobile/modules/student/education/data/models/assessment_question_model.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_question.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_assessment.dart';

class LectureAssessmentModel extends LectureAssessment {
  const LectureAssessmentModel({
    required super.id,
    required super.lectureId,
    required super.title,
    required super.questions,
    super.totalMarks,
  });

  factory LectureAssessmentModel.fromJson(Map<String, dynamic> json) {
    return LectureAssessmentModel(
      id: json['id'] as String? ?? json['objectId'] as String? ?? '',
      lectureId: _parseLectureId(json['lecture']),
      title: json['title'] as String? ?? '',
      questions: _parseQuestions(json['questions']),
      totalMarks: (json['totalMarks'] as num?)?.toDouble() ?? 0,
    );
  }

  static String _parseLectureId(dynamic value) {
    if (value is Map) {
      return (value['id'] ?? value['objectId'])?.toString() ?? '';
    }
    if (value is String) return value;
    return '';
  }

  /// The API returns each question as a JSON-encoded string
  /// (`questions: string[]` in swagger, but each entry is really
  /// `{question, choices[], correctAnswerIndex}` stringified).
  static List<AssessmentQuestion> _parseQuestions(dynamic value) {
    if (value is! List) return const [];
    final result = <AssessmentQuestion>[];
    for (final entry in value) {
      try {
        final decoded = entry is String
            ? jsonDecode(entry) as Map<String, dynamic>
            : Map<String, dynamic>.from(entry as Map);
        result.add(AssessmentQuestionModel.fromJson(decoded));
      } catch (e) {
        Logger().w('Skipping malformed assessment question: $e');
      }
    }
    return result;
  }
}
