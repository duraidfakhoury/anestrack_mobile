import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/home/data/datasources/student_dashboard_data_source.dart';
import 'package:anestrack_mobile/modules/student/home/domain/entities/student_dashboard.dart';
import 'package:anestrack_mobile/modules/student/home/domain/parameters/get_student_dashboard_parameters.dart';
import 'package:anestrack_mobile/modules/student/home/domain/repositories/student_dashboard_repository.dart';

class StudentDashboardRepositoryImpl extends StudentDashboardRepository {
  final StudentDashboardDataSource dataSource;

  StudentDashboardRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, StudentDashboardStats>> getDashboard(
    GetStudentDashboardParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.getDashboard(parameters),
    );
  }
}
