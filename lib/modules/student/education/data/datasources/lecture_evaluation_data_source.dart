import 'package:anestrack_mobile/modules/student/education/domain/parameters/create_lecture_evaluation_parameters.dart';

abstract class LectureEvaluationDataSource {
  Future<void> createEvaluation(CreateLectureEvaluationParameters parameters);
}
