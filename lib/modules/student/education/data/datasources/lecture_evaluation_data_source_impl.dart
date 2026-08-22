import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_evaluation_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/create_lecture_evaluation_parameters.dart';

class LectureEvaluationDataSourceImpl extends LectureEvaluationDataSource {
  final Logger _logger = Logger();

  @override
  Future<void> createEvaluation(
    CreateLectureEvaluationParameters parameters,
  ) async {
    try {
      _logger.i('Rating lecture ${parameters.lectureId}: ${parameters.rating}');
      await NetworkHelper().post(
        ApisUrls().createLectureEvaluation,
        data: parameters.toJson(),
      );
    } catch (e) {
      _logger.e('Failed to rate lecture ${parameters.lectureId}: $e');
      rethrow;
    }
  }
}
