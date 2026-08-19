import 'package:anestrack_mobile/modules/supervisor/home/data/models/supervisor_dashboard_model.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/parameters/get_supervisor_dashboard_parameters.dart';

abstract class SupervisorDashboardDataSource {
  Future<SupervisorDashboardModel> getDashboard(
    GetSupervisorDashboardParameters parameters,
  );
}
