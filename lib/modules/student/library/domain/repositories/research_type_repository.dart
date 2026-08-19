import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_type.dart';

abstract class ResearchTypeRepository {
  Future<Either<Failure, List<ResearchType>>> listResearchTypes();
}
