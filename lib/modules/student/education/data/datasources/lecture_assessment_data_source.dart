import 'package:anestrack_mobile/modules/student/education/data/models/assessment_result_model.dart';
import 'package:anestrack_mobile/modules/student/education/data/models/lecture_assessment_model.dart';

abstract class LectureAssessmentDataSource {
  Future<List<LectureAssessmentModel>> listLectureAssessments({
    required String lectureId,
    int? limit,
  });

  Future<AssessmentResultModel> submitAnswers({
    required String assessmentId,
    required List<int> answers,
  });
}
