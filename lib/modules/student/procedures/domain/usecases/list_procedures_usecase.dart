import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';

class ListProceduresUseCase {
  final ProcedureRepository repository;

  ListProceduresUseCase(this.repository);

  Future call(ListProceduresParameters parameters) {
    return repository.listProcedures(parameters);
  }
}
