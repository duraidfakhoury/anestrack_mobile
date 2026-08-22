import 'package:equatable/equatable.dart';

/// A student's attendance row for a lecture (`LectureAttendance` Parse class,
/// integration §8).
class LectureAttendance extends Equatable {
  final String id;
  final String lectureId;
  final String studentId;
  final String? attendedAt;
  final bool completed;

  const LectureAttendance({
    required this.id,
    this.lectureId = '',
    this.studentId = '',
    this.attendedAt,
    this.completed = false,
  });

  @override
  List<Object?> get props => [id, lectureId, studentId, attendedAt, completed];
}
