import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import '../entities/hospital.dart';
import '../entities/procedure_type.dart';
import '../entities/supervisor.dart';

abstract class HospitalRepository {
  Future<Either<Failure, List<Hospital>>> listHospitals();
}

abstract class ProcedureTypeRepository {
  Future<Either<Failure, List<ProcedureType>>> listProcedureTypes();
}

abstract class SupervisorRepository {
  Future<Either<Failure, List<Supervisor>>> listSupervisors();
}
