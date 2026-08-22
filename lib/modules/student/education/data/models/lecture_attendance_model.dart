import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_attendance.dart';

class LectureAttendanceModel extends LectureAttendance {
  const LectureAttendanceModel({
    required super.id,
    super.lectureId,
    super.studentId,
    super.attendedAt,
    super.completed,
  });

  /// Handles both shapes: the raw row from `recordAttendance`/`updateAttendance`
  /// (`objectId`, pointer refs) and the mapped row from `listAttendance`
  /// (`id`, expanded `lecture`/`student`).
  factory LectureAttendanceModel.fromJson(Map<String, dynamic> json) {
    return LectureAttendanceModel(
      id: json['id'] as String? ?? json['objectId'] as String? ?? '',
      lectureId: _refId(json['lecture']),
      studentId: _refId(json['student']),
      attendedAt: _parseDate(json['attendedAt']),
      completed: json['completed'] as bool? ?? false,
    );
  }

  static String _refId(dynamic value) {
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
