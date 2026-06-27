import 'package:anestrack_mobile/modules/student/procedures/data/models/procedure_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';

abstract class ProcedureDataSource {
  Future<List<ProcedureModel>> listProcedures(
    ListProceduresParameters parameters,
  );

  Future<bool> createProcedure(
    CreateProcedureParameters parameters,
  );
}
