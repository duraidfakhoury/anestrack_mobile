import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/entities/supervisor_dashboard.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/parameters/get_supervisor_dashboard_parameters.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/repositories/supervisor_dashboard_repository.dart';

class GetSupervisorDashboardUseCase {
  final SupervisorDashboardRepository repository;

  GetSupervisorDashboardUseCase(this.repository);

  Future<Either<Failure, SupervisorDashboardStats>> call(
    GetSupervisorDashboardParameters parameters,
  ) {
    return repository.getDashboard(parameters);
  }
}
