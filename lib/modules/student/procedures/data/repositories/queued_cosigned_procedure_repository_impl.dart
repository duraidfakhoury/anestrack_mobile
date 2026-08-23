import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/queued_cosigned_procedure_local_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/models/queued_cosigned_procedure_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/queued_cosigned_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/offline_cosigned_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/queued_cosigned_procedure_repository.dart';

class QueuedCosignedProcedureRepositoryImpl
    implements QueuedCosignedProcedureRepository {
  final QueuedCosignedProcedureLocalDataSource dataSource;

  QueuedCosignedProcedureRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, QueuedCosignedProcedure>> enqueue(
    OfflineCosignedProcedureParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(() async {
      final items = await dataSource.listAll();
      final item = QueuedCosignedProcedureModel(
        // The QR's crypto localId, not a freshly-minted one — it must stay
        // identical across retries (spec rule §8.5).
        localId: parameters.localId,
        parameters: parameters,
        queuedAt: DateTime.now(),
      );
      items.add(item);
      await dataSource.saveAll(items);
      return item;
    });
  }

  @override
  Future<Either<Failure, List<QueuedCosignedProcedure>>> listPending() {
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
      items[idx] = QueuedCosignedProcedureModel.fromEntity(
        items[idx].copyWith(
          status: QueuedCosignedProcedureStatus.failed,
          retryCount: items[idx].retryCount + 1,
          lastErrorMessage: errorMessage,
        ),
      );
      await dataSource.saveAll(items);
    });
  }
}
