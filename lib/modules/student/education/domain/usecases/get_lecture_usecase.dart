import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_repository.dart';

class GetLectureUseCase {
  final LectureRepository repository;

  GetLectureUseCase(this.repository);

  Future<Either<Failure, Lecture>> call(String id) => repository.getLecture(id);
}
