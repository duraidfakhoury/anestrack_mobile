import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/home/domain/entities/student_dashboard.dart';
import 'package:anestrack_mobile/modules/student/home/domain/parameters/get_student_dashboard_parameters.dart';

abstract class StudentDashboardRepository {
  Future<Either<Failure, StudentDashboardStats>> getDashboard(
    GetStudentDashboardParameters parameters,
  );
}
