import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_cosign_qr_payload.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';

sealed class CreateProcedureEvent extends Equatable {
  const CreateProcedureEvent();
}

class SubmitCreateProcedureEvent extends CreateProcedureEvent {
  final CreateProcedureParameters parameters;

  const SubmitCreateProcedureEvent(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

/// Dispatched after the student sees the "you're offline" prompt (following
/// a `SubmitCreateProcedureEvent` that resolved to [offlineNeedsDecision])
/// and chooses to save without a supervisor's signature.
class QueuePlainOfflineProcedureEvent extends CreateProcedureEvent {
  final CreateProcedureParameters parameters;

  const QueuePlainOfflineProcedureEvent(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

/// Dispatched after the student scans a supervisor's bedside QR from the
/// offline prompt.
class QueueCoSignedOfflineProcedureEvent extends CreateProcedureEvent {
  final CreateProcedureParameters parameters;
  final OfflineCoSignQrPayload scannedAttestation;

  const QueueCoSignedOfflineProcedureEvent(
    this.parameters,
    this.scannedAttestation,
  );

  @override
  List<Object?> get props => [parameters, scannedAttestation];
}

class ResetCreateProcedureEvent extends CreateProcedureEvent {
  const ResetCreateProcedureEvent();

  @override
  List<Object?> get props => [];
}
