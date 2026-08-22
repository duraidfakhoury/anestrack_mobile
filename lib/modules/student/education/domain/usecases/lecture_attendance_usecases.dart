import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_attendance.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_attendance_repository.dart';

class EnsureAttendanceUseCase {
  final LectureAttendanceRepository repository;
  EnsureAttendanceUseCase(this.repository);

  Future<Either<Failure, LectureAttendance>> call({
    required String lectureId,
    required String studentId,
  }) => repository.ensureAttendance(lectureId: lectureId, studentId: studentId);
}

class MarkAttendanceCompletedUseCase {
  final LectureAttendanceRepository repository;
  MarkAttendanceCompletedUseCase(this.repository);

  Future<Either<Failure, LectureAttendance>> call(String attendanceId) =>
      repository.markCompleted(attendanceId);
}
