import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';

abstract class ProcedureRepository {
  Future<Either<Failure, List<Procedure>>> listProcedures(
    ListProceduresParameters parameters,
  );

  Future<Either<Failure, bool>> createProcedure(
    CreateProcedureParameters parameters,
  );
}
