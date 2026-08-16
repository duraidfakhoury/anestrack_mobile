import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';

class ResearchPaperModel extends ResearchPaper {
  const ResearchPaperModel({
    required super.id,
    required super.title,
    required super.description,
    super.authors,
    super.fileUrl,
    super.publishedAt,
    super.studentName,
  });

  factory ResearchPaperModel.fromJson(Map<String, dynamic> json) {
    return ResearchPaperModel(
      id: json['objectId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      authors:
          (json['authors'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      fileUrl: json['file'] as String?,
      publishedAt: _parseDate(json['publishedAt']),
      studentName: _userFullName(json['student']),
    );
  }

  static String? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map && value['iso'] != null) return value['iso'] as String;
    return null;
  }

  static String? _userFullName(dynamic value) {
    if (value is Map) {
      final first = (value['FirstName'] as String?) ?? '';
      final last = (value['LastName'] as String?) ?? '';
      final full = '$first $last'.trim();
      if (full.isNotEmpty) return full;
    }
    return null;
  }
}
