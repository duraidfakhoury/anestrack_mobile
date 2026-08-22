import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_attendance_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/data/models/lecture_attendance_model.dart';

class LectureAttendanceDataSourceImpl extends LectureAttendanceDataSource {
  final Logger _logger = Logger();

  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  @override
  Future<LectureAttendanceModel> recordAttendance(String lectureId) async {
    try {
      _logger.i('Recording attendance for lecture $lectureId');
      final response = await NetworkHelper().post(
        ApisUrls().recordAttendance,
        data: {'lectureId': lectureId},
      );
      final body = _unwrap(response.data);
      return LectureAttendanceModel.fromJson(Map<String, dynamic>.from(body as Map));
    } catch (e) {
      _logger.e('Failed to record attendance for lecture $lectureId: $e');
      rethrow;
    }
  }

  @override
  Future<LectureAttendanceModel> updateAttendance({
    required String id,
    required bool completed,
  }) async {
    try {
      _logger.i('Updating attendance $id (completed=$completed)');
      // `completed` must be a real boolean, not "true" (integration §8).
      final response = await NetworkHelper().put(
        ApisUrls().updateAttendance,
        data: {'id': id, 'completed': completed},
      );
      final body = _unwrap(response.data);
      return LectureAttendanceModel.fromJson(Map<String, dynamic>.from(body as Map));
    } catch (e) {
      _logger.e('Failed to update attendance $id: $e');
      rethrow;
    }
  }

  @override
  Future<List<LectureAttendanceModel>> listAttendance({
    String? lectureId,
    int? limit,
  }) async {
    try {
      _logger.i('Listing attendance for lecture $lectureId');
      final response = await NetworkHelper().get(
        ApisUrls().listAttendance,
        data: {
          if (lectureId != null) 'lectureId': lectureId,
          if (limit != null) 'limit': limit,
        },
      );
      final body = _unwrap(response.data);
      if (body is List) {
        return body
            .whereType<Map>()
            .map((e) => LectureAttendanceModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      _logger.w('Unexpected attendance response: ${response.data}');
      return [];
    } catch (e) {
      _logger.e('Failed to list attendance: $e');
      rethrow;
    }
  }
}
