import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/student/complaints/data/datasources/complaint_data_source.dart';
import 'package:anestrack_mobile/modules/student/complaints/domain/parameters/create_complaint_parameters.dart';

class ComplaintDataSourceImpl extends ComplaintDataSource {
  final Logger _logger = Logger();

  @override
  Future<void> createComplaint(CreateComplaintParameters parameters) async {
    try {
      _logger.i('Submitting complaint: ${parameters.title}');
      await NetworkHelper().post(
        ApisUrls().createComplaint,
        data: parameters.toJson(),
      );
      _logger.i('Complaint submitted');
    } catch (e) {
      _logger.e('Failed to submit complaint: $e');
      rethrow;
    }
  }
}
