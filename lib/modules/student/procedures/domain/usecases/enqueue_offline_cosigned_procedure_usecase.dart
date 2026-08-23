import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_cosign_qr_payload.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/queued_cosigned_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/offline_cosigned_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/queued_cosigned_procedure_repository.dart';

/// Queues a co-signed offline entry once the student has both filled the
/// form and scanned the supervisor's QR. Sets `capturedAt` here, at the
/// moment the entry is actually queued — never user-editable, never the
/// later sync time (spec rule §8.4).
class EnqueueOfflineCoSignedProcedureUseCase {
  final QueuedCosignedProcedureRepository repository;

  EnqueueOfflineCoSignedProcedureUseCase(this.repository);

  Future<Either<Failure, QueuedCosignedProcedure>> call({
    required CreateProcedureParameters form,
    required OfflineCoSignQrPayload scannedAttestation,
  }) {
    final parameters = OfflineCosignedProcedureParameters(
      hospitalId: form.hospitalId,
      procedureTypeIds: form.procedureTypeIds,
      patientName: form.patientName,
      procedureDate: form.procedureDate,
      capturedAt: DateTime.now().toUtc().toIso8601String(),
      localId: scannedAttestation.localId,
      coSignCode: scannedAttestation.code,
      notes: form.notes,
    );
    return repository.enqueue(parameters);
  }
}
