import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';

class LectureModel extends Lecture {
  const LectureModel({
    required super.id,
    required super.title,
    required super.description,
    super.contentType,
    super.mainGoals,
    super.withTest,
    super.createdAt,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['objectId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      contentType: json['contentType'] as String?,
      mainGoals: (json['mainGoals'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      withTest: json['withTest'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static String? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map && value['iso'] != null) return value['iso'] as String;
    return null;
  }
}
