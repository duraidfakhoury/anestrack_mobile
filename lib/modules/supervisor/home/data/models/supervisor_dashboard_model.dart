import 'package:anestrack_mobile/modules/supervisor/home/domain/entities/supervisor_dashboard.dart';

/// Parses the `getSupervisorDashboard` cloud-function result. Field names
/// are confirmed against a live response:
/// ```json
/// {
///   "hospitalId": "All",
///   "totals": { "total": 21, "pending": 5, "approved": 15, "rejected": 1 },
///   "totalStudents": 6,
///   "pendingReview": 5,
///   "byProcedureType": [ { "procedureTypeId": "...", "name": "...", "count": 5 }, ... ]
/// }
/// ```
class SupervisorDashboardModel extends SupervisorDashboardStats {
  const SupervisorDashboardModel({
    required super.totalProcedures,
    required super.approvedProcedures,
    required super.rejectedProcedures,
    required super.pendingReview,
    required super.totalStudents,
    required super.byProcedureType,
  });

  factory SupervisorDashboardModel.fromJson(Map<String, dynamic> json) {
    final totals = (json['totals'] as Map?)?.cast<String, dynamic>() ?? const {};

    return SupervisorDashboardModel(
      totalProcedures: (totals['total'] as num?)?.toInt() ?? 0,
      approvedProcedures: (totals['approved'] as num?)?.toInt() ?? 0,
      rejectedProcedures: (totals['rejected'] as num?)?.toInt() ?? 0,
      pendingReview:
          (json['pendingReview'] as num?)?.toInt() ??
          (totals['pending'] as num?)?.toInt() ??
          0,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      byProcedureType: _readByProcedureType(json['byProcedureType']),
    );
  }

  static List<ProcedureTypeCount> _readByProcedureType(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          return ProcedureTypeCount(
            procedureTypeId: map['procedureTypeId'] as String? ?? '',
            name: map['name'] as String? ?? '',
            count: (map['count'] as num?)?.toInt() ?? 0,
          );
        })
        .toList();
  }
}
