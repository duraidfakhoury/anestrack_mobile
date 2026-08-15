import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/complaints/data/datasources/complaint_data_source.dart';
import 'package:anestrack_mobile/modules/student/complaints/domain/parameters/create_complaint_parameters.dart';
import 'package:anestrack_mobile/modules/student/complaints/domain/repositories/complaint_repository.dart';

class ComplaintRepositoryImpl extends ComplaintRepository {
  final ComplaintDataSource dataSource;

  ComplaintRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Unit>> createComplaint(
    CreateComplaintParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(() async {
      await dataSource.createComplaint(parameters);
      return unit;
    });
  }
}
