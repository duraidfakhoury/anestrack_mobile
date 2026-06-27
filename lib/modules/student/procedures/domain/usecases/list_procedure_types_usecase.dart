import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure_type.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/hospital_procedure_type_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';

class ListProcedureTypesUseCase {
  final ProcedureTypeRepository repository;

  ListProcedureTypesUseCase(this.repository);

  Future<Either<Failure, List<ProcedureType>>> call() {
    return repository.listProcedureTypes();
  }
}
