import 'package:anestrack_mobile/modules/student/complaints/domain/parameters/create_complaint_parameters.dart';

abstract class ComplaintDataSource {
  Future<void> createComplaint(CreateComplaintParameters parameters);
}
