import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/co_sign_context.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/co_sign_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/confirm_procedure_parameters.dart';

abstract class ProcedureRepository {
  /// Student — list procedures (with optional filters).
  Future<Either<Failure, List<Procedure>>> listProcedures(
    ListProceduresParameters parameters,
  );

  /// Student — log a procedure. Returns the created procedure plus, for a live
  /// co-sign request, the one-time co-sign code.
  Future<Either<Failure, CreateProcedureResult>> createProcedure(
    CreateProcedureParameters parameters,
  );

  /// Supervisor — co-sign a procedure live at the point of care (Flow 1).
  Future<Either<Failure, Procedure>> coSignProcedure(
    CoSignParameters parameters,
  );

  /// Supervisor — preview a scanned co-sign code before tapping.
  Future<Either<Failure, CoSignContext>> getCoSignContext(String coSignCode);

  /// Supervisor — confirm or reject an async procedure (Flow 2/3).
  Future<Either<Failure, Procedure>> confirmProcedure(
    ConfirmProcedureParameters parameters,
  );

  /// Supervisor — everything awaiting this supervisor (co-signs + confirmations).
  Future<Either<Failure, List<Procedure>>> listPendingForSupervisor();
}
