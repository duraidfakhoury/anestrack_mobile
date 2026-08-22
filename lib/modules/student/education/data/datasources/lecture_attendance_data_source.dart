import 'package:anestrack_mobile/modules/student/education/data/models/lecture_attendance_model.dart';

abstract class LectureAttendanceDataSource {
  Future<LectureAttendanceModel> recordAttendance(String lectureId);

  Future<LectureAttendanceModel> updateAttendance({
    required String id,
    required bool completed,
  });

  Future<List<LectureAttendanceModel>> listAttendance({
    String? lectureId,
    int? limit,
  });
}
