import 'package:anestrack_mobile/modules/supervisor/reviews/domain/entities/offline_attestation.dart';

class OfflineAttestationModel extends OfflineAttestation {
  const OfflineAttestationModel({
    required super.localId,
    required super.code,
    required super.witnessedAt,
    super.note,
    required super.queuedAt,
    super.status,
    super.retryCount,
    super.lastErrorMessage,
  });

  factory OfflineAttestationModel.fromJson(Map<String, dynamic> json) {
    return OfflineAttestationModel(
      localId: json['localId'] as String,
      code: json['code'] as String,
      witnessedAt: json['witnessedAt'] as String,
      note: json['note'] as String?,
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      status: OfflineAttestationStatus.values.byName(
        json['status'] as String? ?? 'pending',
      ),
      retryCount: json['retryCount'] as int? ?? 0,
      lastErrorMessage: json['lastErrorMessage'] as String?,
    );
  }

  factory OfflineAttestationModel.fromEntity(OfflineAttestation entity) {
    if (entity is OfflineAttestationModel) return entity;
    return OfflineAttestationModel(
      localId: entity.localId,
      code: entity.code,
      witnessedAt: entity.witnessedAt,
      note: entity.note,
      queuedAt: entity.queuedAt,
      status: entity.status,
      retryCount: entity.retryCount,
      lastErrorMessage: entity.lastErrorMessage,
    );
  }

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'code': code,
    'witnessedAt': witnessedAt,
    if (note != null) 'note': note,
    'queuedAt': queuedAt.toIso8601String(),
    'status': status.name,
    'retryCount': retryCount,
    if (lastErrorMessage != null) 'lastErrorMessage': lastErrorMessage,
  };
}
