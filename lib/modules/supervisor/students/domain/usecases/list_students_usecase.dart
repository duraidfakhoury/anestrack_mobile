import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/entities/student.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/parameters/list_students_parameters.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/repositories/student_repository.dart';

class ListStudentsUseCase {
  final StudentRepository repository;

  ListStudentsUseCase(this.repository);

  Future<Either<Failure, List<Student>>> call(
    ListStudentsParameters parameters,
  ) {
    return repository.listStudents(parameters);
  }
}
