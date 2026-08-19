import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/supervisor/home/data/datasources/supervisor_dashboard_data_source.dart';
import 'package:anestrack_mobile/modules/supervisor/home/data/models/supervisor_dashboard_model.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/parameters/get_supervisor_dashboard_parameters.dart';

class SupervisorDashboardDataSourceImpl extends SupervisorDashboardDataSource {
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
  Future<SupervisorDashboardModel> getDashboard(
    GetSupervisorDashboardParameters parameters,
  ) async {
    try {
      _logger.i("Fetching supervisor dashboard: ${parameters.toJson()}");
      final response = await NetworkHelper().get(
        ApisUrls().getSupervisorDashboard,
        data: parameters.toJson(),
      );

      final unwrapped = _unwrap(response.data);
      if (unwrapped is Map) {
        final dashboard = SupervisorDashboardModel.fromJson(
          Map<String, dynamic>.from(unwrapped),
        );
        _logger.i("Fetched supervisor dashboard");
        return dashboard;
      }

      _logger.w("Unexpected dashboard response format: ${response.data}");
      return SupervisorDashboardModel.fromJson(const {});
    } catch (e) {
      _logger.e("Failed to fetch supervisor dashboard: $e");
      rethrow;
    }
  }
}
