import 'package:equatable/equatable.dart';

/// A logged medical procedure with its reliability scoring, as returned by the
/// backend `Procedure` class. Fields mirror the AnesTrack reliability system:
/// a 0–10 [reliabilityScore] and an [assuranceLevel] of Verified / Attested /
/// Flagged, plus the individual trust signals that build the score.
class Procedure extends Equatable {
  final String id;

  // Core
  final String status; // Pending, Approved, Rejected, UnderInvestigation, Revoked
  final String patientName;
  final String? procedureDate; // ISO-8601
  final String? createdAt; // ISO-8601
  final String? notes;
  final bool isOffline;
  final bool isEmergency;

  // Related (pointer) data — names are only present when the backend included them
  final String? hospitalId;
  final String? hospitalName;
  final String? procedureTypeId;
  final String? procedureTypeName;
  final String? studentId;
  final String? studentName;
  final String? supervisorId;
  final String? supervisorName;

  // Reliability
  final int? reliabilityScore; // 0..10
  final String? assuranceLevel; // Verified, Attested, Flagged
  final List<String> reliabilityFlags; // e.g. BULK_ENTRY, BACKDATED

  // Trust signals
  final bool liveCoSign;
  final bool proximityVerified;
  final bool asyncConfirmed;
  final bool bodyPhoto;

  // Live co-sign flow (Flow 1)
  final String? coSignStatus; // NotRequested, Awaiting, CoSigned, Expired
  final String? coSignExpiresAt; // ISO-8601

  // Async confirmation flow (Flow 2/3)
  final String?
  confirmationStatus; // NotRequired, PendingConfirmation, Confirmed, Rejected, Expired
  final String? confirmationDeadline; // ISO-8601

  // Integrity update — populated only once an admin has opened an
  // investigation, revoked, or reinstated this record.
  final String? statusBeforeIntegrityAction;
  final String? integrityAction; // OpenInvestigation, Revoke, Reinstate
  final String?
  integrityReason; // Fabrication, PatientMismatch, DuplicateEntry, SupervisorDenial, UnauthorizedApproval, AdminError, Other
  final String? integrityNote;
  final String? integrityActionAt; // ISO-8601
  final String? integrityActionByName;

  // Multi-type sessions — several procedure types logged for one bedside
  // event share a `sessionId`. `sessionSize` is 1 for an ordinary single-type
  // procedure too, so it's always safe to read.
  final String? sessionId;
  final int? sessionSize;

  const Procedure({
    required this.id,
    required this.status,
    required this.patientName,
    this.procedureDate,
    this.createdAt,
    this.notes,
    this.isOffline = false,
    this.isEmergency = false,
    this.hospitalId,
    this.hospitalName,
    this.procedureTypeId,
    this.procedureTypeName,
    this.studentId,
    this.studentName,
    this.supervisorId,
    this.supervisorName,
    this.reliabilityScore,
    this.assuranceLevel,
    this.reliabilityFlags = const [],
    this.liveCoSign = false,
    this.proximityVerified = false,
    this.asyncConfirmed = false,
    this.bodyPhoto = false,
    this.coSignStatus,
    this.coSignExpiresAt,
    this.confirmationStatus,
    this.confirmationDeadline,
    this.statusBeforeIntegrityAction,
    this.integrityAction,
    this.integrityReason,
    this.integrityNote,
    this.integrityActionAt,
    this.integrityActionByName,
    this.sessionId,
    this.sessionSize,
  });

  /// Whether this record is still waiting on a supervisor co-sign or confirmation.
  bool get isAwaitingCoSign => coSignStatus == 'Awaiting';
  bool get isPendingConfirmation => confirmationStatus == 'PendingConfirmation';

  /// Frozen or struck by an admin — read-only, and no longer counts towards
  /// the training log.
  bool get isUnderIntegrityAction =>
      status == 'UnderInvestigation' || status == 'Revoked';

  @override
  List<Object?> get props => [
    id,
    status,
    patientName,
    procedureDate,
    createdAt,
    notes,
    isOffline,
    isEmergency,
    hospitalId,
    hospitalName,
    procedureTypeId,
    procedureTypeName,
    studentId,
    studentName,
    supervisorId,
    supervisorName,
    reliabilityScore,
    assuranceLevel,
    reliabilityFlags,
    liveCoSign,
    proximityVerified,
    asyncConfirmed,
    bodyPhoto,
    coSignStatus,
    coSignExpiresAt,
    confirmationStatus,
    confirmationDeadline,
    statusBeforeIntegrityAction,
    integrityAction,
    integrityReason,
    integrityNote,
    integrityActionAt,
    integrityActionByName,
    sessionId,
    sessionSize,
  ];
}
