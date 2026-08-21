import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/home/domain/entities/student_dashboard.dart';
import 'package:anestrack_mobile/modules/student/home/domain/parameters/get_student_dashboard_parameters.dart';
import 'package:anestrack_mobile/modules/student/home/domain/repositories/student_dashboard_repository.dart';

class GetStudentDashboardUseCase {
  final StudentDashboardRepository repository;

  GetStudentDashboardUseCase(this.repository);

  Future<Either<Failure, StudentDashboardStats>> call(
    GetStudentDashboardParameters parameters,
  ) {
    return repository.getDashboard(parameters);
  }
}
