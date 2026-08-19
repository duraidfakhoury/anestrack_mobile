import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/entities/supervisor_dashboard.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/parameters/get_supervisor_dashboard_parameters.dart';

abstract class SupervisorDashboardRepository {
  Future<Either<Failure, SupervisorDashboardStats>> getDashboard(
    GetSupervisorDashboardParameters parameters,
  );
}
