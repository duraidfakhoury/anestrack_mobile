import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_repository.dart';

class LectureRepositoryImpl extends LectureRepository {
  final LectureDataSource dataSource;

  LectureRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Lecture>>> listLectures() {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.listLectures(),
    );
  }
}
