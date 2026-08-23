import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/core/utils/secure_hex_id.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/data/datasources/offline_attestation_local_data_source.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/data/models/offline_attestation_model.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/domain/entities/offline_attestation.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/domain/repositories/offline_attestation_repository.dart';

class OfflineAttestationRepositoryImpl implements OfflineAttestationRepository {
  final OfflineAttestationLocalDataSource dataSource;

  OfflineAttestationRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, OfflineAttestation>> mintAndEnqueue({String? note}) {
    return AppErrorsHandler().defaultHandleEither(() async {
      final items = await dataSource.listAll();
      final item = OfflineAttestationModel(
        localId: SecureHexId.generate(12),
        code: SecureHexId.generate(16),
        witnessedAt: DateTime.now().toUtc().toIso8601String(),
        note: note,
        queuedAt: DateTime.now(),
      );
      items.add(item);
      // Persisted before returning — the caller (the "generate" button
      // handler) must await this before building the QR widget.
      await dataSource.saveAll(items);
      return item;
    });
  }

  @override
  Future<Either<Failure, List<OfflineAttestation>>> listPending() {
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
      items[idx] = OfflineAttestationModel.fromEntity(
        items[idx].copyWith(
          status: OfflineAttestationStatus.failed,
          retryCount: items[idx].retryCount + 1,
          lastErrorMessage: errorMessage,
        ),
      );
      await dataSource.saveAll(items);
    });
  }
}
