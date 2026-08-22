import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_attendance.dart';

abstract class LectureAttendanceRepository {
  /// Ensures the logged-in student has exactly one attendance row for the
  /// lecture: looks it up via `listAttendance` (matching [studentId]) and only
  /// records a new one if none exists — the backend does not de-duplicate
  /// (integration §8).
  Future<Either<Failure, LectureAttendance>> ensureAttendance({
    required String lectureId,
    required String studentId,
  });

  Future<Either<Failure, LectureAttendance>> markCompleted(String attendanceId);
}
