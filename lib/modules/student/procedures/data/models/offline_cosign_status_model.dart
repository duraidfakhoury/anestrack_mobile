import 'package:anestrack_mobile/modules/student/procedures/data/models/procedure_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_cosign_status.dart';

class OfflineCoSignClaimModel extends OfflineCoSignClaim {
  const OfflineCoSignClaimModel({
    required super.id,
    required super.localId,
    super.sessionId,
    required super.status,
    super.capturedAt,
    super.submittedAt,
    super.expiresAt,
    super.matchedAt,
    super.clockSkewMinutes,
    super.supervisorId,
    super.supervisorName,
  });

  factory OfflineCoSignClaimModel.fromJson(Map<String, dynamic> json) {
    return OfflineCoSignClaimModel(
      id: (json['id'] ?? json['objectId']) as String? ?? '',
      localId: json['localId'] as String? ?? '',
      sessionId: json['sessionId'] as String?,
      status: json['status'] as String? ?? 'AwaitingAttestation',
      capturedAt: ProcedureModel.parseDate(json['capturedAt']),
      submittedAt: ProcedureModel.parseDate(json['submittedAt']),
      expiresAt: ProcedureModel.parseDate(json['expiresAt']),
      matchedAt: ProcedureModel.parseDate(json['matchedAt']),
      clockSkewMinutes: (json['clockSkewMinutes'] as num?)?.toInt(),
      supervisorId: json['supervisorId'] as String?,
      supervisorName: json['supervisorName'] as String?,
    );
  }
}

class OfflineCoSignAttestationModel extends OfflineCoSignAttestation {
  const OfflineCoSignAttestationModel({
    required super.id,
    required super.localId,
    required super.witnessedAt,
    super.submittedAt,
    super.expiresAt,
    super.matched,
    super.expired,
    super.matchedAt,
    super.claimedByName,
    super.note,
  });

  factory OfflineCoSignAttestationModel.fromJson(Map<String, dynamic> json) {
    return OfflineCoSignAttestationModel(
      id: (json['id'] ?? json['objectId']) as String? ?? '',
      localId: json['localId'] as String? ?? '',
      witnessedAt: ProcedureModel.parseDate(json['witnessedAt']) ?? '',
      submittedAt: ProcedureModel.parseDate(json['submittedAt']),
      expiresAt: ProcedureModel.parseDate(json['expiresAt']),
      matched: json['matched'] as bool? ?? false,
      expired: json['expired'] as bool? ?? false,
      matchedAt: ProcedureModel.parseDate(json['matchedAt']),
      claimedByName: json['claimedByName'] as String?,
      note: json['note'] as String?,
    );
  }
}

class OfflineCoSignStatusModel extends OfflineCoSignStatus {
  const OfflineCoSignStatusModel({super.claims, super.attestations});

  factory OfflineCoSignStatusModel.fromJson(Map<String, dynamic> json) {
    return OfflineCoSignStatusModel(
      claims:
          (json['claims'] as List?)
              ?.map(
                (e) => OfflineCoSignClaimModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      attestations:
          (json['attestations'] as List?)
              ?.map(
                (e) => OfflineCoSignAttestationModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
    );
  }
}
