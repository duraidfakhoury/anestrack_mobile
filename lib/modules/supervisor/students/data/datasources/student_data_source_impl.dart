import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/supervisor/students/data/datasources/student_data_source.dart';
import 'package:anestrack_mobile/modules/supervisor/students/data/models/student_model.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/parameters/list_students_parameters.dart';

class StudentDataSourceImpl extends StudentDataSource {
  final Logger _logger = Logger();

  /// `/api/functions/*` strips the Parse `result` wrapper, so the body is the
  /// raw return value. We still tolerate a `{result: ...}` envelope defensively.
  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  @override
  Future<List<StudentModel>> listStudents(
    ListStudentsParameters parameters,
  ) async {
    try {
      _logger.i("Fetching students: ${parameters.toJson()}");
      // `listStudents` is already scoped to Students server-side (assertSupervisor),
      // so no userType filter is needed here.
      final response = await NetworkHelper().get(
        ApisUrls().listStudents,
        data: parameters.toJson(),
      );

      final unwrapped = _unwrap(response.data);
      if (unwrapped is List) {
        final students = unwrapped
            .whereType<Map>()
            .map((e) => StudentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _logger.i("Fetched ${students.length} students");
        return students;
      }

      _logger.w("Unexpected students response format: ${response.data}");
      return [];
    } catch (e) {
      _logger.e("Failed to fetch students: $e");
      rethrow;
    }
  }
}
