import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/student/home/data/datasources/student_dashboard_data_source.dart';
import 'package:anestrack_mobile/modules/student/home/data/models/student_dashboard_model.dart';
import 'package:anestrack_mobile/modules/student/home/domain/parameters/get_student_dashboard_parameters.dart';

class StudentDashboardDataSourceImpl extends StudentDashboardDataSource {
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
  Future<StudentDashboardModel> getDashboard(
    GetStudentDashboardParameters parameters,
  ) async {
    try {
      _logger.i("Fetching student dashboard: ${parameters.toJson()}");
      final response = await NetworkHelper().get(
        ApisUrls().getStudentDashboard,
        data: parameters.toJson(),
      );

      final unwrapped = _unwrap(response.data);
      if (unwrapped is Map) {
        final dashboard = StudentDashboardModel.fromJson(
          Map<String, dynamic>.from(unwrapped),
        );
        _logger.i("Fetched student dashboard");
        return dashboard;
      }

      _logger.w("Unexpected dashboard response format: ${response.data}");
      return StudentDashboardModel.fromJson(const {});
    } catch (e) {
      _logger.e("Failed to fetch student dashboard: $e");
      rethrow;
    }
  }
}
