import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/co_sign_context.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';

class GetCoSignContextUseCase {
  final ProcedureRepository repository;

  GetCoSignContextUseCase(this.repository);

  Future<Either<Failure, CoSignContext>> call(String coSignCode) {
    return repository.getCoSignContext(coSignCode);
  }
}
