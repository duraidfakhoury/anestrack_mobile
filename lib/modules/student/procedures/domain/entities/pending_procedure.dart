import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';

enum PendingProcedureStatus { pending, failed }

/// A procedure that was submitted while offline, saved locally, and is
/// awaiting automatic sync to the backend once connectivity returns. See
/// [SyncPendingProceduresUseCase] for how the queue drains.
class PendingProcedure extends Equatable {
  final String localId;
  final CreateProcedureParameters parameters;
  final DateTime queuedAt;
  final PendingProcedureStatus status;
  final int retryCount;
  final String? lastErrorMessage;

  const PendingProcedure({
    required this.localId,
    required this.parameters,
    required this.queuedAt,
    this.status = PendingProcedureStatus.pending,
    this.retryCount = 0,
    this.lastErrorMessage,
  });

  PendingProcedure copyWith({
    PendingProcedureStatus? status,
    int? retryCount,
    String? lastErrorMessage,
  }) {
    return PendingProcedure(
      localId: localId,
      parameters: parameters,
      queuedAt: queuedAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    localId,
    parameters,
    queuedAt,
    status,
    retryCount,
    lastErrorMessage,
  ];
}
