import 'package:anestrack_mobile/modules/student/procedures/data/models/procedure_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/models/co_sign_context_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/co_sign_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/confirm_procedure_parameters.dart';

abstract class ProcedureDataSource {
  Future<List<ProcedureModel>> listProcedures(
    ListProceduresParameters parameters,
  );

  Future<CreateProcedureResult> createProcedure(
    CreateProcedureParameters parameters,
  );

  Future<ProcedureModel> coSignProcedure(CoSignParameters parameters);

  Future<CoSignContextModel> getCoSignContext(String coSignCode);

  Future<ProcedureModel> confirmProcedure(
    ConfirmProcedureParameters parameters,
  );

  Future<List<ProcedureModel>> listPendingForSupervisor();
}
