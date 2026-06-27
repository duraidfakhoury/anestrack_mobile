import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';

class CreateProcedureUseCase {
  final ProcedureRepository repository;

  CreateProcedureUseCase(this.repository);

  Future call(CreateProcedureParameters parameters) {
    return repository.createProcedure(parameters);
  }
}
