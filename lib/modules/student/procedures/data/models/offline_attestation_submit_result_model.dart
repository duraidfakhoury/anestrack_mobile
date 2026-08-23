import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_attestation_submit_result.dart';

class OfflineAttestationSubmitResultRowModel
    extends OfflineAttestationSubmitResultRow {
  const OfflineAttestationSubmitResultRowModel({
    required super.index,
    required super.success,
    super.attestationId,
    super.matched,
    super.procedureIds,
    super.clockSkewMinutes,
    super.flaggedForReview,
    super.alreadySubmitted,
    super.detail,
  });

  factory OfflineAttestationSubmitResultRowModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OfflineAttestationSubmitResultRowModel(
      index: (json['index'] as num?)?.toInt() ?? 0,
      success: json['success'] as bool? ?? false,
      attestationId: json['attestationId'] as String?,
      matched: json['matched'] as bool? ?? false,
      procedureIds:
          (json['procedureIds'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      clockSkewMinutes: (json['clockSkewMinutes'] as num?)?.toInt(),
      flaggedForReview: json['flaggedForReview'] as bool? ?? false,
      alreadySubmitted: json['alreadySubmitted'] as bool? ?? false,
      detail: json['detail'] as String?,
    );
  }
}

class OfflineAttestationSubmitResultModel extends OfflineAttestationSubmitResult {
  const OfflineAttestationSubmitResultModel({
    required super.successCount,
    required super.failureCount,
    required super.matchedCount,
    required super.results,
  });

  factory OfflineAttestationSubmitResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OfflineAttestationSubmitResultModel(
      successCount: (json['successCount'] as num?)?.toInt() ?? 0,
      failureCount: (json['failureCount'] as num?)?.toInt() ?? 0,
      matchedCount: (json['matchedCount'] as num?)?.toInt() ?? 0,
      results:
          (json['results'] as List?)
              ?.map(
                (e) => OfflineAttestationSubmitResultRowModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
    );
  }
}
