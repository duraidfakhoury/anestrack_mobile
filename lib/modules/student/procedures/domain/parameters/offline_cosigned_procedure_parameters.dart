import 'package:equatable/equatable.dart';

/// One queued bedside event for `syncOfflineCoSignedProcedures`. A distinct
/// shape from `CreateProcedureParameters` — this endpoint is deliberately
/// isolated from `createProcedure`/`syncOfflineProcedures` (see
/// `integration-mobile-offline-cosign.md` §10) and must not be folded back
/// into them.
class OfflineCosignedProcedureParameters extends Equatable {
  final String hospitalId;
  final List<String> procedureTypeIds;
  final String patientName;
  final String procedureDate;

  /// Device clock at the moment the entry was written — never the sync
  /// time, never user-editable (spec rule §8.4).
  final String capturedAt;

  /// From the scanned QR. The idempotency key on this endpoint — must stay
  /// identical across retries (spec rule §8.5).
  final String localId;

  /// From the scanned QR. Never logged, never sent anywhere but this
  /// endpoint (spec rule §8.7).
  final String coSignCode;

  final String? notes;

  /// Optional non-identifying body photo as a base64 string (no data-URI
  /// prefix) — same shape as `CreateProcedureParameters.photo`. Not shown
  /// in the spec doc's §6.1 example, but the backend accepts it here too.
  final String? photo;

  const OfflineCosignedProcedureParameters({
    required this.hospitalId,
    required this.procedureTypeIds,
    required this.patientName,
    required this.procedureDate,
    required this.capturedAt,
    required this.localId,
    required this.coSignCode,
    this.notes,
    this.photo,
  });

  Map<String, dynamic> toJson() => {
    'hospitalId': hospitalId,
    'procedureTypeIds': procedureTypeIds,
    'patientName': patientName,
    'procedureDate': procedureDate,
    'capturedAt': capturedAt,
    'localId': localId,
    'coSignCode': coSignCode,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    if (photo != null && photo!.isNotEmpty) 'photo': photo,
  };

  @override
  List<Object?> get props => [
    hospitalId,
    procedureTypeIds,
    patientName,
    procedureDate,
    capturedAt,
    localId,
    coSignCode,
    notes,
    photo,
  ];
}
