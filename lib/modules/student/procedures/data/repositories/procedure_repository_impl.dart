import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/procedure_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/co_sign_context.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/co_sign_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/confirm_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/evaluation_parameters.dart';
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
  Future<Either<Failure, CreateProcedureResult>> createProcedure(
    CreateProcedureParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.createProcedure(parameters),
    );
  }

  @override
  Future<Either<Failure, Procedure>> coSignProcedure(
    CoSignParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.coSignProcedure(parameters),
    );
  }

  @override
  Future<Either<Failure, CoSignContext>> getCoSignContext(String coSignCode) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.getCoSignContext(coSignCode),
    );
  }

  @override
  Future<Either<Failure, Procedure>> getProcedure(String id) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.getProcedure(id),
    );
  }

  @override
  Future<Either<Failure, Procedure>> confirmProcedure(
    ConfirmProcedureParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.confirmProcedure(parameters),
    );
  }

  @override
  Future<Either<Failure, List<Procedure>>> listPendingForSupervisor() {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.listPendingForSupervisor(),
    );
  }

  @override
  Future<Either<Failure, bool>> createEvaluation(
    EvaluationParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.createEvaluation(parameters),
    );
  }
}
