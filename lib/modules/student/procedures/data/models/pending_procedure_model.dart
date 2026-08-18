import 'package:anestrack_mobile/modules/student/procedures/domain/entities/pending_procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';

/// Local-storage codec for [CreateProcedureParameters]. The domain class only
/// has `toJson` (it's normally write-only, sent straight to the backend) —
/// this adds the read side, needed only to round-trip a queued item through
/// local storage.
extension CreateProcedureParametersLocalCodec on CreateProcedureParameters {
  static CreateProcedureParameters fromJson(Map<String, dynamic> json) {
    return CreateProcedureParameters(
      hospitalId: json['hospitalId'] as String,
      procedureTypeId: json['procedureTypeId'] as String,
      patientName: json['patientName'] as String,
      procedureDate: json['procedureDate'] as String,
      supervisorId: json['supervisorId'] as String?,
      notes: json['notes'] as String?,
      isOffline: json['isOffline'] as bool? ?? false,
      requestLiveCoSign: json['requestLiveCoSign'] as bool? ?? false,
      isEmergency: json['isEmergency'] as bool? ?? false,
      photo: json['photo'] as String?,
    );
  }
}

class PendingProcedureModel extends PendingProcedure {
  const PendingProcedureModel({
    required super.localId,
    required super.parameters,
    required super.queuedAt,
    super.status,
    super.retryCount,
    super.lastErrorMessage,
  });

  factory PendingProcedureModel.fromJson(Map<String, dynamic> json) {
    return PendingProcedureModel(
      localId: json['localId'] as String,
      parameters: CreateProcedureParametersLocalCodec.fromJson(
        json['parameters'] as Map<String, dynamic>,
      ),
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      status: PendingProcedureStatus.values.byName(
        json['status'] as String? ?? 'pending',
      ),
      retryCount: json['retryCount'] as int? ?? 0,
      lastErrorMessage: json['lastErrorMessage'] as String?,
    );
  }

  factory PendingProcedureModel.fromEntity(PendingProcedure entity) {
    if (entity is PendingProcedureModel) return entity;
    return PendingProcedureModel(
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
