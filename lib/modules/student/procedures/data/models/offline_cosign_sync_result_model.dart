import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_cosign_sync_result.dart';

class OfflineCoSignSyncResultRowModel extends OfflineCoSignSyncResultRow {
  const OfflineCoSignSyncResultRowModel({
    required super.index,
    required super.success,
    super.claimId,
    super.sessionId,
    super.procedureIds,
    super.coSigned,
    super.coSignPending,
    super.clockSkewMinutes,
    super.flaggedForReview,
    super.alreadySynced,
    super.detail,
  });

  factory OfflineCoSignSyncResultRowModel.fromJson(Map<String, dynamic> json) {
    return OfflineCoSignSyncResultRowModel(
      index: (json['index'] as num?)?.toInt() ?? 0,
      success: json['success'] as bool? ?? false,
      claimId: json['claimId'] as String?,
      sessionId: json['sessionId'] as String?,
      procedureIds:
          (json['procedureIds'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      coSigned: json['coSigned'] as bool? ?? false,
      coSignPending: json['coSignPending'] as bool? ?? false,
      clockSkewMinutes: (json['clockSkewMinutes'] as num?)?.toInt(),
      flaggedForReview: json['flaggedForReview'] as bool? ?? false,
      alreadySynced: json['alreadySynced'] as bool? ?? false,
      detail: json['detail'] as String?,
    );
  }
}

class OfflineCoSignSyncResultModel extends OfflineCoSignSyncResult {
  const OfflineCoSignSyncResultModel({
    required super.successCount,
    required super.failureCount,
    required super.coSignedCount,
    required super.pendingCount,
    required super.results,
  });

  factory OfflineCoSignSyncResultModel.fromJson(Map<String, dynamic> json) {
    return OfflineCoSignSyncResultModel(
      successCount: (json['successCount'] as num?)?.toInt() ?? 0,
      failureCount: (json['failureCount'] as num?)?.toInt() ?? 0,
      coSignedCount: (json['coSignedCount'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
      results:
          (json['results'] as List?)
              ?.map(
                (e) => OfflineCoSignSyncResultRowModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
    );
  }
}
