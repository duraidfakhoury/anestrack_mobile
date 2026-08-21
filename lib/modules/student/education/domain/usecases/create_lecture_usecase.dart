import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/create_lecture_parameters.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_repository.dart';

class CreateLectureUseCase {
  final LectureRepository repository;

  CreateLectureUseCase(this.repository);

  Future<Either<Failure, Lecture>> call(CreateLectureParameters parameters) =>
      repository.createLecture(parameters);
}
