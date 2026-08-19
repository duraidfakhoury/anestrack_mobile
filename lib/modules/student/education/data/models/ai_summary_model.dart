import 'package:anestrack_mobile/modules/student/education/domain/entities/ai_summary.dart';

class AiSummaryModel extends AiSummary {
  const AiSummaryModel({
    required super.id,
    required super.lectureId,
    required super.summaryContent,
    super.contentType,
    super.createdAt,
  });

  factory AiSummaryModel.fromJson(Map<String, dynamic> json) {
    return AiSummaryModel(
      id: json['id'] as String? ?? json['objectId'] as String? ?? '',
      lectureId: _parseLectureId(json['lecture']),
      summaryContent: json['summaryContent'] as String? ?? '',
      contentType: json['contentType'] as String?,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static String _parseLectureId(dynamic value) {
    if (value is Map) {
      return (value['id'] ?? value['objectId'])?.toString() ?? '';
    }
    if (value is String) return value;
    return '';
  }

  static String? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map && value['iso'] != null) return value['iso'] as String;
    return null;
  }
}
