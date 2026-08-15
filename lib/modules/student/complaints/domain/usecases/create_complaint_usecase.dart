import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/complaints/domain/parameters/create_complaint_parameters.dart';
import 'package:anestrack_mobile/modules/student/complaints/domain/repositories/complaint_repository.dart';

class CreateComplaintUseCase {
  final ComplaintRepository repository;

  CreateComplaintUseCase(this.repository);

  Future<Either<Failure, Unit>> call(CreateComplaintParameters parameters) =>
      repository.createComplaint(parameters);
}
