import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/library/data/datasources/research_data_source.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/domain/repositories/research_repository.dart';

class ResearchRepositoryImpl extends ResearchRepository {
  final ResearchDataSource dataSource;

  ResearchRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ResearchPaper>>> listResearchPapers() {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.listResearchPapers(),
    );
  }
}
