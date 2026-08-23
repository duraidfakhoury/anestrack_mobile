import 'package:equatable/equatable.dart';

/// One row of `submitOfflineAttestations`'s response — the outcome of
/// uploading a single locally-minted attestation. See
/// `integration-mobile-offline-cosign.md` §6.2.
class OfflineAttestationSubmitResultRow extends Equatable {
  final int index;
  final bool success;
  final String? attestationId;

  /// `false` with `detail: "Waiting for the student to sync the
  /// procedure"` is the expected outcome when the supervisor syncs first —
  /// show it as pending, never as failed.
  final bool matched;
  final List<String> procedureIds;
  final int? clockSkewMinutes;
  final bool flaggedForReview;

  /// This `localId` was already submitted — treat as success, clear the
  /// outbox row.
  final bool alreadySubmitted;

  /// Human-readable; safe to log, not written for end users.
  final String? detail;

  const OfflineAttestationSubmitResultRow({
    required this.index,
    required this.success,
    this.attestationId,
    this.matched = false,
    this.procedureIds = const [],
    this.clockSkewMinutes,
    this.flaggedForReview = false,
    this.alreadySubmitted = false,
    this.detail,
  });

  @override
  List<Object?> get props => [
    index,
    success,
    attestationId,
    matched,
    procedureIds,
    clockSkewMinutes,
    flaggedForReview,
    alreadySubmitted,
    detail,
  ];
}

class OfflineAttestationSubmitResult extends Equatable {
  final int successCount;
  final int failureCount;
  final int matchedCount;
  final List<OfflineAttestationSubmitResultRow> results;

  const OfflineAttestationSubmitResult({
    required this.successCount,
    required this.failureCount,
    required this.matchedCount,
    required this.results,
  });

  @override
  List<Object?> get props => [successCount, failureCount, matchedCount, results];
}
