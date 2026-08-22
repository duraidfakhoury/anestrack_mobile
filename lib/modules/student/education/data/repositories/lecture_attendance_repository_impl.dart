import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_attendance_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_attendance.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_attendance_repository.dart';

class LectureAttendanceRepositoryImpl extends LectureAttendanceRepository {
  final LectureAttendanceDataSource dataSource;

  LectureAttendanceRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, LectureAttendance>> ensureAttendance({
    required String lectureId,
    required String studentId,
  }) {
    return AppErrorsHandler().defaultHandleEither(() async {
      // listAttendance returns every student's rows for the lecture, so match
      // ours client-side (§8). If none is ours, record one.
      final existing = await dataSource.listAttendance(lectureId: lectureId);
      final mine = existing.where(
        (a) => studentId.isNotEmpty && a.studentId == studentId,
      );
      if (mine.isNotEmpty) return mine.first;
      return dataSource.recordAttendance(lectureId);
    });
  }

  @override
  Future<Either<Failure, LectureAttendance>> markCompleted(
    String attendanceId,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.updateAttendance(id: attendanceId, completed: true),
    );
  }
}
