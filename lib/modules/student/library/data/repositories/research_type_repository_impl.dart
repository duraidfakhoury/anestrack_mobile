import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/library/data/datasources/research_type_data_source.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_type.dart';
import 'package:anestrack_mobile/modules/student/library/domain/repositories/research_type_repository.dart';

class ResearchTypeRepositoryImpl extends ResearchTypeRepository {
  final ResearchTypeDataSource dataSource;

  ResearchTypeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ResearchType>>> listResearchTypes() {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.listResearchTypes(),
    );
  }
}
