import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/supervisor/home/data/datasources/supervisor_dashboard_data_source.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/entities/supervisor_dashboard.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/parameters/get_supervisor_dashboard_parameters.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/repositories/supervisor_dashboard_repository.dart';

class SupervisorDashboardRepositoryImpl extends SupervisorDashboardRepository {
  final SupervisorDashboardDataSource dataSource;

  SupervisorDashboardRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, SupervisorDashboardStats>> getDashboard(
    GetSupervisorDashboardParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.getDashboard(parameters),
    );
  }
}
