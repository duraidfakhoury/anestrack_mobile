import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/procedure_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';

class ProcedureRepositoryImpl extends ProcedureRepository {
  final ProcedureDataSource dataSource;

  ProcedureRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Procedure>>> listProcedures(
    ListProceduresParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.listProcedures(parameters),
    );
  }

  @override
  Future<Either<Failure, bool>> createProcedure(
    CreateProcedureParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.createProcedure(parameters),
    );
  }
}
