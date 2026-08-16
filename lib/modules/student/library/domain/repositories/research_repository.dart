import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';

abstract class ResearchRepository {
  Future<Either<Failure, List<ResearchPaper>>> listResearchPapers();
}
