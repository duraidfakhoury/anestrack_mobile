import 'package:anestrack_mobile/modules/student/home/data/models/student_dashboard_model.dart';
import 'package:anestrack_mobile/modules/student/home/domain/parameters/get_student_dashboard_parameters.dart';

abstract class StudentDashboardDataSource {
  Future<StudentDashboardModel> getDashboard(
    GetStudentDashboardParameters parameters,
  );
}
