import 'package:equatable/equatable.dart';

/// A student's view of one bedside event they scanned and queued —
/// `getOfflineCoSignStatus`'s `claims[]`. See
/// `integration-mobile-offline-cosign.md` §6.3.
class OfflineCoSignClaim extends Equatable {
  final String id;
  final String localId;
  final String? sessionId;

  /// AwaitingAttestation | Matched | Expired
  final String status;
  final String? capturedAt;
  final String? submittedAt;
  final String? expiresAt;
  final String? matchedAt;
  final int? clockSkewMinutes;
  final String? supervisorId;
  final String? supervisorName;

  const OfflineCoSignClaim({
    required this.id,
    required this.localId,
    this.sessionId,
    required this.status,
    this.capturedAt,
    this.submittedAt,
    this.expiresAt,
    this.matchedAt,
    this.clockSkewMinutes,
    this.supervisorId,
    this.supervisorName,
  });

  bool get isAwaitingAttestation => status == 'AwaitingAttestation';
  bool get isMatched => status == 'Matched';
  bool get isExpired => status == 'Expired';

  @override
  List<Object?> get props => [
    id,
    localId,
    sessionId,
    status,
    capturedAt,
    submittedAt,
    expiresAt,
    matchedAt,
    clockSkewMinutes,
    supervisorId,
    supervisorName,
  ];
}

/// A supervisor's view of one attestation they minted and uploaded —
/// `getOfflineCoSignStatus`'s `attestations[]`.
class OfflineCoSignAttestation extends Equatable {
  final String id;
  final String localId;
  final String witnessedAt;
  final String? submittedAt;
  final String? expiresAt;
  final bool matched;
  final bool expired;
  final String? matchedAt;
  final String? claimedByName;
  final String? note;

  const OfflineCoSignAttestation({
    required this.id,
    required this.localId,
    required this.witnessedAt,
    this.submittedAt,
    this.expiresAt,
    this.matched = false,
    this.expired = false,
    this.matchedAt,
    this.claimedByName,
    this.note,
  });

  @override
  List<Object?> get props => [
    id,
    localId,
    witnessedAt,
    submittedAt,
    expiresAt,
    matched,
    expired,
    matchedAt,
    claimedByName,
    note,
  ];
}

/// `getOfflineCoSignStatus`'s response — filtered to the caller: a student
/// gets [claims] populated and [attestations] empty, a supervisor the
/// reverse.
class OfflineCoSignStatus extends Equatable {
  final List<OfflineCoSignClaim> claims;
  final List<OfflineCoSignAttestation> attestations;

  const OfflineCoSignStatus({
    this.claims = const [],
    this.attestations = const [],
  });

  @override
  List<Object?> get props => [claims, attestations];
}
