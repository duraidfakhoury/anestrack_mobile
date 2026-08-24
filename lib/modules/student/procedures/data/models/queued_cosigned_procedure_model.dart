import 'package:anestrack_mobile/modules/student/procedures/domain/entities/queued_cosigned_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/offline_cosigned_procedure_parameters.dart';

/// Local-storage codec for [OfflineCosignedProcedureParameters]. The domain
/// class only has `toJson` (normally write-only, sent straight to the
/// backend) — this adds the read side, needed only to round-trip a queued
/// item through local storage.
extension OfflineCosignedProcedureParametersLocalCodec
    on OfflineCosignedProcedureParameters {
  static OfflineCosignedProcedureParameters fromJson(
    Map<String, dynamic> json,
  ) {
    return OfflineCosignedProcedureParameters(
      hospitalId: json['hospitalId'] as String,
      procedureTypeIds:
          (json['procedureTypeIds'] as List?)?.map((e) => e as String).toList() ??
          const [],
      patientName: json['patientName'] as String,
      procedureDate: json['procedureDate'] as String,
      capturedAt: json['capturedAt'] as String,
      localId: json['localId'] as String,
      coSignCode: json['coSignCode'] as String,
      notes: json['notes'] as String?,
      photo: json['photo'] as String?,
    );
  }
}

class QueuedCosignedProcedureModel extends QueuedCosignedProcedure {
  const QueuedCosignedProcedureModel({
    required super.localId,
    required super.parameters,
    required super.queuedAt,
    super.status,
    super.retryCount,
    super.lastErrorMessage,
  });

  factory QueuedCosignedProcedureModel.fromJson(Map<String, dynamic> json) {
    return QueuedCosignedProcedureModel(
      localId: json['localId'] as String,
      parameters: OfflineCosignedProcedureParametersLocalCodec.fromJson(
        json['parameters'] as Map<String, dynamic>,
      ),
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      status: QueuedCosignedProcedureStatus.values.byName(
        json['status'] as String? ?? 'pending',
      ),
      retryCount: json['retryCount'] as int? ?? 0,
      lastErrorMessage: json['lastErrorMessage'] as String?,
    );
  }

  factory QueuedCosignedProcedureModel.fromEntity(
    QueuedCosignedProcedure entity,
  ) {
    if (entity is QueuedCosignedProcedureModel) return entity;
    return QueuedCosignedProcedureModel(
      localId: entity.localId,
      parameters: entity.parameters,
      queuedAt: entity.queuedAt,
      status: entity.status,
      retryCount: entity.retryCount,
      lastErrorMessage: entity.lastErrorMessage,
    );
  }

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'parameters': parameters.toJson(),
    'queuedAt': queuedAt.toIso8601String(),
    'status': status.name,
    'retryCount': retryCount,
    if (lastErrorMessage != null) 'lastErrorMessage': lastErrorMessage,
  };
}
