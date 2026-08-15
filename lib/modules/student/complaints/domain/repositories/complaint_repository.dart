import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/complaints/domain/parameters/create_complaint_parameters.dart';

abstract class ComplaintRepository {
  Future<Either<Failure, Unit>> createComplaint(
    CreateComplaintParameters parameters,
  );
}
