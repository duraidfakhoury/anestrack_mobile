import 'package:anestrack_mobile/modules/supervisor/students/data/models/student_model.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/parameters/list_students_parameters.dart';

abstract class StudentDataSource {
  Future<List<StudentModel>> listStudents(ListStudentsParameters parameters);
}
