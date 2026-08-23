import 'package:equatable/equatable.dart';

/// One row of `syncOfflineCoSignedProcedures`'s response — the outcome of
/// uploading a single queued bedside event. See
/// `integration-mobile-offline-cosign.md` §6.1.
class OfflineCoSignSyncResultRow extends Equatable {
  final int index;
  final bool success;
  final String? claimId;
  final String? sessionId;
  final List<String> procedureIds;

  /// The supervisor's half was already there — this procedure is Approved
  /// and fully scored.
  final bool coSigned;

  /// Uploaded fine, still waiting for the supervisor. Not an error.
  final bool coSignPending;

  /// Absent until matched.
  final int? clockSkewMinutes;

  /// Matched, co-signed, and sent to an admin because the clocks disagreed
  /// past 15 minutes.
  final bool flaggedForReview;

  /// This `localId` was already uploaded — treat as success, clear the queue.
  final bool alreadySynced;

  /// Human-readable; safe to log, not written for end users.
  final String? detail;

  const OfflineCoSignSyncResultRow({
    required this.index,
    required this.success,
    this.claimId,
    this.sessionId,
    this.procedureIds = const [],
    this.coSigned = false,
    this.coSignPending = false,
    this.clockSkewMinutes,
    this.flaggedForReview = false,
    this.alreadySynced = false,
    this.detail,
  });

  @override
  List<Object?> get props => [
    index,
    success,
    claimId,
    sessionId,
    procedureIds,
    coSigned,
    coSignPending,
    clockSkewMinutes,
    flaggedForReview,
    alreadySynced,
    detail,
  ];
}

class OfflineCoSignSyncResult extends Equatable {
  final int successCount;
  final int failureCount;
  final int coSignedCount;
  final int pendingCount;
  final List<OfflineCoSignSyncResultRow> results;

  const OfflineCoSignSyncResult({
    required this.successCount,
    required this.failureCount,
    required this.coSignedCount,
    required this.pendingCount,
    required this.results,
  });

  @override
  List<Object?> get props => [
    successCount,
    failureCount,
    coSignedCount,
    pendingCount,
    results,
  ];
}
