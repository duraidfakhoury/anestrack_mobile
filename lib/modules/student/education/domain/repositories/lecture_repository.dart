import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/create_lecture_parameters.dart';

abstract class LectureRepository {
  Future<Either<Failure, List<Lecture>>> listLectures({int? limit, int? skip});
  Future<Either<Failure, Lecture>> getLecture(String id);
  Future<Either<Failure, Lecture>> createLecture(
    CreateLectureParameters parameters,
  );
}
