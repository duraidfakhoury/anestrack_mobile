import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';

class GetProcedureUseCase {
  final ProcedureRepository repository;

  GetProcedureUseCase(this.repository);

  Future<Either<Failure, Procedure>> call(String id) {
    return repository.getProcedure(id);
  }
}
