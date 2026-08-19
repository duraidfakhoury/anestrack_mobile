import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_type.dart';
import 'package:anestrack_mobile/modules/student/library/domain/repositories/research_type_repository.dart';

class ListResearchTypesUseCase {
  final ResearchTypeRepository repository;

  ListResearchTypesUseCase(this.repository);

  Future<Either<Failure, List<ResearchType>>> call() =>
      repository.listResearchTypes();
}
