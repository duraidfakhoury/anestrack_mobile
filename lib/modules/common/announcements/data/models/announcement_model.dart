import 'package:anestrack_mobile/modules/common/announcements/domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.objectId ,
    required super.title,
    required super.content,
    super.isImportant,
    super.createdAt,
    required super.targetGroup,
    required super.isActive,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      objectId: json['objectId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isImportant: json['isImportant'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
      targetGroup: json['targetGroup'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  static String? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map && value['iso'] != null) return value['iso'] as String;
    return null;
  }
}
