import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/offline_cosigned_procedure_parameters.dart';

enum QueuedCosignedProcedureStatus { pending, failed }

/// A procedure entry the student scanned a supervisor's bedside QR for,
/// saved locally, awaiting automatic sync to `syncOfflineCoSignedProcedures`
/// once connectivity returns. A separate queue from `PendingProcedure` —
/// see `integration-mobile-offline-cosign.md` §10, they must not be folded
/// together.
class QueuedCosignedProcedure extends Equatable {
  /// Mirrors `parameters.localId` (the QR's crypto id) — kept as a
  /// top-level field so repository CRUD doesn't need to reach into
  /// `parameters`. Stays identical across retries (spec rule §8.5).
  final String localId;

  final OfflineCosignedProcedureParameters parameters;
  final DateTime queuedAt;
  final QueuedCosignedProcedureStatus status;
  final int retryCount;
  final String? lastErrorMessage;

  const QueuedCosignedProcedure({
    required this.localId,
    required this.parameters,
    required this.queuedAt,
    this.status = QueuedCosignedProcedureStatus.pending,
    this.retryCount = 0,
    this.lastErrorMessage,
  });

  QueuedCosignedProcedure copyWith({
    QueuedCosignedProcedureStatus? status,
    int? retryCount,
    String? lastErrorMessage,
  }) {
    return QueuedCosignedProcedure(
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
