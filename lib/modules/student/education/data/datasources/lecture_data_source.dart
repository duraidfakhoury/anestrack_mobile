import 'package:anestrack_mobile/modules/student/education/data/models/lecture_model.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/create_lecture_parameters.dart';

abstract class LectureDataSource {
  Future<List<LectureModel>> listLectures({int? limit, int? skip});
  Future<LectureModel> getLecture(String id);
  Future<LectureModel> createLecture(CreateLectureParameters parameters);
}
