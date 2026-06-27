import 'package:anestrack_mobile/modules/student/procedures/domain/entities/hospital.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/hospital_procedure_type_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';

class ListHospitalsUseCase {
  final HospitalRepository repository;

  ListHospitalsUseCase(this.repository);

  Future<Either<Failure, List<Hospital>>> call() {
    return repository.listHospitals();
  }
}
