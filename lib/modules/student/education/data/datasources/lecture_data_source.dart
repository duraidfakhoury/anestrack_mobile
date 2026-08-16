import 'package:anestrack_mobile/modules/student/education/data/models/lecture_model.dart';

abstract class LectureDataSource {
  Future<List<LectureModel>> listLectures();
}
