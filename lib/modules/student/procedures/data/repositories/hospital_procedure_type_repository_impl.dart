import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/reference_data_local_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/hospital.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure_type.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/supervisor.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/hospital_procedure_type_repository.dart';
import '../datasources/hospital_procedure_type_data_source.dart';

class HospitalRepositoryImpl implements HospitalRepository {
  final HospitalProcedureTypeDataSource dataSource;
  final ReferenceDataLocalDataSource localDataSource;

  HospitalRepositoryImpl(this.dataSource, this.localDataSource);

  @override
  Future<Either<Failure, List<Hospital>>> listHospitals() async {
    final result = await AppErrorsHandler().defaultHandleEither(() async {
      final models = await dataSource.listHospitals();
      return models
          .map(
            (model) => Hospital(
              id: model.id,
              name: model.name,
              address: model.address,
              contactInfo: model.contactInfo,
              isActive: model.isActive,
            ),
          )
          .toList();
    });

    return result.fold(
      (failure) async {
        // Device offline and we have a previously fetched list — fall back
        // to it rather than leaving the dropdown empty. Any other failure
        // (server error, parsing, etc.) still surfaces normally.
        if (failure is NoInternetFailure) {
          final cached = await localDataSource.getCachedHospitals();
          if (cached != null) return Right(cached);
        }
        return Left(failure);
      },
      (hospitals) async {
        await localDataSource.cacheHospitals(hospitals);
        return Right(hospitals);
      },
    );
  }
}

class ProcedureTypeRepositoryImpl implements ProcedureTypeRepository {
  final HospitalProcedureTypeDataSource dataSource;
  final ReferenceDataLocalDataSource localDataSource;

  ProcedureTypeRepositoryImpl(this.dataSource, this.localDataSource);

  @override
  Future<Either<Failure, List<ProcedureType>>> listProcedureTypes() async {
    final result = await AppErrorsHandler().defaultHandleEither(() async {
      final models = await dataSource.listProcedureTypes();
      return models
          .map(
            (model) => ProcedureType(
              id: model.id,
              name: model.name,
              isActive: model.isActive,
            ),
          )
          .toList();
    });

    return result.fold(
      (failure) async {
        if (failure is NoInternetFailure) {
          final cached = await localDataSource.getCachedProcedureTypes();
          if (cached != null) return Right(cached);
        }
        return Left(failure);
      },
      (procedureTypes) async {
        await localDataSource.cacheProcedureTypes(procedureTypes);
        return Right(procedureTypes);
      },
    );
  }
}

class SupervisorRepositoryImpl implements SupervisorRepository {
  final HospitalProcedureTypeDataSource dataSource;
  final ReferenceDataLocalDataSource localDataSource;

  SupervisorRepositoryImpl(this.dataSource, this.localDataSource);

  @override
  Future<Either<Failure, List<Supervisor>>> listSupervisors() async {
    final result = await AppErrorsHandler().defaultHandleEither(() async {
      final models = await dataSource.listSupervisors();
      return models
          .map((model) => Supervisor.fromJson(model.toJson()))
          .toList();
    });

    return result.fold(
      (failure) async {
        if (failure is NoInternetFailure) {
          final cached = await localDataSource.getCachedSupervisors();
          if (cached != null) return Right(cached);
        }
        return Left(failure);
      },
      (supervisors) async {
        await localDataSource.cacheSupervisors(supervisors);
        return Right(supervisors);
      },
    );
  }
}
