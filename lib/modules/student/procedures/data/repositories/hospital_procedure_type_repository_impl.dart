import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/hospital.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure_type.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/supervisor.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/hospital_procedure_type_repository.dart';
import '../datasources/hospital_procedure_type_data_source.dart';

class HospitalRepositoryImpl implements HospitalRepository {
  final HospitalProcedureTypeDataSource dataSource;

  HospitalRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Hospital>>> listHospitals() async {
    return AppErrorsHandler().defaultHandleEither(() async {
      final models = await dataSource.listHospitals();
      return models
          .map(
            (model) => Hospital(
              objectId: model.objectId,
              name: model.name,
              address: model.address,
              contactInfo: model.contactInfo,
              isActive: model.isActive,
            ),
          )
          .toList();
    });
  }
}

class ProcedureTypeRepositoryImpl implements ProcedureTypeRepository {
  final HospitalProcedureTypeDataSource dataSource;

  ProcedureTypeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ProcedureType>>> listProcedureTypes() async {
    return AppErrorsHandler().defaultHandleEither(() async {
      final models = await dataSource.listProcedureTypes();
      return models
          .map(
            (model) => ProcedureType(
              objectId: model.objectId,
              name: model.name,
              isActive: model.isActive,
            ),
          )
          .toList();
    });
  }
}

class SupervisorRepositoryImpl implements SupervisorRepository {
  final HospitalProcedureTypeDataSource dataSource;

  SupervisorRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Supervisor>>> listSupervisors() async {
    return AppErrorsHandler().defaultHandleEither(() async {
      final models = await dataSource.listSupervisors();
      return models
          .map((model) => Supervisor.fromJson(model.toJson()))
          .toList();
    });
  }
}
