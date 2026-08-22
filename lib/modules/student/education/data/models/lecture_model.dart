import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_file.dart';

class LectureModel extends Lecture {
  const LectureModel({
    required super.id,
    required super.title,
    required super.description,
    super.contentType,
    super.contentText,
    super.contentUrl,
    super.contentFile,
    super.mainGoals,
    super.withTest,
    super.assessmentId,
    super.createdAt,
    super.isActive,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      // Normalise the two id shapes at the edge (integration §3).
      id: json['id'] as String? ?? json['objectId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      contentType: json['contentType'] as String?,
      contentText: json['contentText'] as String?,
      contentUrl: json['contentUrl'] as String?,
      contentFile: _parseFile(json['contentFile']),
      mainGoals:
          (json['mainGoals'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      withTest: json['withTest'] as bool? ?? false,
      assessmentId: _parsePointerId(json['assessment']),
      createdAt: _parseDate(json['createdAt']),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static LectureFile? _parseFile(dynamic value) {
    if (value is! Map) return null;
    final map = Map<String, dynamic>.from(value);
    // The URL lives inside the nested Parse File object.
    final file = map['file'];
    String? url;
    String? name;
    if (file is Map) {
      url = file['url'] as String?;
      name = file['name'] as String?;
    }
    final id = (map['id'] ?? map['objectId'])?.toString() ?? '';
    if (id.isEmpty && (url == null || url.isEmpty)) return null;
    return LectureFile(
      id: id,
      url: url,
      type: map['type'] as String?,
      fileSize: (map['fileSize'] as num?)?.toInt(),
      name: name,
    );
  }

  static String? _parsePointerId(dynamic value) {
    if (value is Map) {
      final id = (value['id'] ?? value['objectId'])?.toString();
      return (id == null || id.isEmpty) ? null : id;
    }
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static String? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map && value['iso'] != null) return value['iso'] as String;
    return null;
  }
}
