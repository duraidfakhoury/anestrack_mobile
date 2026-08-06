import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/entities/student.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/parameters/list_students_parameters.dart';

abstract class StudentRepository {
  /// Supervisor — list students (with optional year/pagination filters).
  Future<Either<Failure, List<Student>>> listStudents(
    ListStudentsParameters parameters,
  );
}
