import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/pending_procedure_local_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/models/pending_procedure_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/pending_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/pending_procedure_repository.dart';

class PendingProcedureRepositoryImpl implements PendingProcedureRepository {
  final PendingProcedureLocalDataSource dataSource;

  PendingProcedureRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, PendingProcedure>> enqueue(
    CreateProcedureParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(() async {
      final items = await dataSource.listAll();
      final item = PendingProcedureModel(
        localId: DateTime.now().microsecondsSinceEpoch.toString(),
        parameters: parameters,
        queuedAt: DateTime.now(),
      );
      items.add(item);
      await dataSource.saveAll(items);
      return item;
    });
  }

  @override
  Future<Either<Failure, List<PendingProcedure>>> listPending() {
    return AppErrorsHandler().defaultHandleEither(() => dataSource.listAll());
  }

  @override
  Future<Either<Failure, void>> remove(String localId) {
    return AppErrorsHandler().defaultHandleEither(() async {
      final items = await dataSource.listAll();
      items.removeWhere((e) => e.localId == localId);
      await dataSource.saveAll(items);
    });
  }

  @override
  Future<Either<Failure, void>> markFailed(
    String localId,
    String errorMessage,
  ) {
    return AppErrorsHandler().defaultHandleEither(() async {
      final items = await dataSource.listAll();
      final idx = items.indexWhere((e) => e.localId == localId);
      if (idx == -1) return;
      items[idx] = PendingProcedureModel.fromEntity(
        items[idx].copyWith(
          status: PendingProcedureStatus.failed,
          retryCount: items[idx].retryCount + 1,
          lastErrorMessage: errorMessage,
        ),
      );
      await dataSource.saveAll(items);
    });
  }
}
