import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_assessment_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/data/models/assessment_result_model.dart';
import 'package:anestrack_mobile/modules/student/education/data/models/lecture_assessment_model.dart';

class LectureAssessmentDataSourceImpl extends LectureAssessmentDataSource {
  final Logger _logger = Logger();

  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  @override
  Future<List<LectureAssessmentModel>> listLectureAssessments({
    required String lectureId,
    int? limit,
  }) async {
    try {
      _logger.i('Fetching assessments for lecture $lectureId');
      final response = await NetworkHelper().get(
        ApisUrls().listLectureAssessments,
        data: {'lectureId': lectureId, if (limit != null) 'limit': limit},
      );
      final body = _unwrap(response.data);
      if (body is List) {
        return body
            .whereType<Map>()
            .map(
              (e) => LectureAssessmentModel.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
      }
      _logger.w('Unexpected assessments response: ${response.data}');
      return [];
    } catch (e) {
      _logger.e('Failed to fetch assessments for lecture $lectureId: $e');
      rethrow;
    }
  }

  @override
  Future<AssessmentResultModel> submitAnswers({
    required String assessmentId,
    required List<int> answers,
  }) async {
    try {
      _logger.i('Submitting answers for assessment $assessmentId');
      final response = await NetworkHelper().post(
        ApisUrls().submitAnswers,
        data: {'assessmentId': assessmentId, 'answers': jsonEncode(answers)},
      );
      final body = _unwrap(response.data);
      final result = AssessmentResultModel.fromJson(
        Map<String, dynamic>.from(body as Map),
      );
      // The submit response doesn't always echo back the assessmentId;
      // fall back to the id we submitted with if it's missing.
      return result.assessmentId.isEmpty
          ? AssessmentResultModel(
              assessmentId: assessmentId,
              answers: result.answers,
              score: result.score,
              correctCount: result.correctCount,
            )
          : result;
    } catch (e) {
      _logger.e('Failed to submit answers for assessment $assessmentId: $e');
      rethrow;
    }
  }
}
