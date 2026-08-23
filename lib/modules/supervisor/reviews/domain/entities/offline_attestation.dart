import 'package:equatable/equatable.dart';

enum OfflineAttestationStatus { pending, failed }

/// A bedside attestation minted on this supervisor's device, queued locally
/// until connectivity returns. Mirrors the student side's `PendingProcedure`
/// queue structurally, but is a separate, supervisor-only outbox — see
/// `integration-mobile-offline-cosign.md` §4 and §10.
class OfflineAttestation extends Equatable {
  /// 24 lowercase hex chars. Minted on this device, stays identical across
  /// retries (spec rule §8.5).
  final String localId;

  /// 32 lowercase hex chars. The shared secret — never logged, never sent
  /// anywhere but `submitOfflineAttestations` (spec rule §8.7).
  final String code;

  /// ISO-8601 UTC with milliseconds, this device's clock at the moment the
  /// QR was shown.
  final String witnessedAt;

  /// Optional free text so the supervisor can recognise what they signed
  /// days later. Never scored.
  final String? note;

  final DateTime queuedAt;
  final OfflineAttestationStatus status;
  final int retryCount;
  final String? lastErrorMessage;

  const OfflineAttestation({
    required this.localId,
    required this.code,
    required this.witnessedAt,
    this.note,
    required this.queuedAt,
    this.status = OfflineAttestationStatus.pending,
    this.retryCount = 0,
    this.lastErrorMessage,
  });

  OfflineAttestation copyWith({
    OfflineAttestationStatus? status,
    int? retryCount,
    String? lastErrorMessage,
  }) {
    return OfflineAttestation(
      localId: localId,
      code: code,
      witnessedAt: witnessedAt,
      note: note,
      queuedAt: queuedAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    localId,
    code,
    witnessedAt,
    note,
    queuedAt,
    status,
    retryCount,
    lastErrorMessage,
  ];
}
