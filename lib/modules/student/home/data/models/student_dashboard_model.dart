import 'package:anestrack_mobile/modules/student/home/domain/entities/student_dashboard.dart';

/// Parses the `getStudentDashboard` cloud-function result. Field names are
/// confirmed against a live response:
/// ```json
/// {
///   "studentId": "lyeFQRnCFS",
///   "totals": { "total": 1, "pending": 0, "approved": 1, "rejected": 0 },
///   "byProcedureType": [ { "procedureTypeId": "...", "name": "...", "count": 1 } ],
///   "evaluation": {
///     "counts": { "Excellent": 0, "Good": 0, "Acceptable": 0, "Poor": 0 },
///     "totalEvaluated": 0,
///     "averageScore": 0,
///     "performance": "Not Evaluated"
///   }
/// }
/// ```
class StudentDashboardModel extends StudentDashboardStats {
  const StudentDashboardModel({
    required super.totalProcedures,
    required super.pendingProcedures,
    required super.approvedProcedures,
    required super.rejectedProcedures,
    required super.byProcedureType,
    required super.evaluation,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    final totals = (json['totals'] as Map?)?.cast<String, dynamic>() ?? const {};

    return StudentDashboardModel(
      totalProcedures: (totals['total'] as num?)?.toInt() ?? 0,
      pendingProcedures: (totals['pending'] as num?)?.toInt() ?? 0,
      approvedProcedures: (totals['approved'] as num?)?.toInt() ?? 0,
      rejectedProcedures: (totals['rejected'] as num?)?.toInt() ?? 0,
      byProcedureType: _readByProcedureType(json['byProcedureType']),
      evaluation: _readEvaluation(json['evaluation']),
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

  static StudentEvaluationSummary _readEvaluation(dynamic raw) {
    final map = (raw as Map?)?.cast<String, dynamic>() ?? const {};
    final counts = (map['counts'] as Map?)?.cast<String, dynamic>() ?? const {};

    return StudentEvaluationSummary(
      excellentCount: (counts['Excellent'] as num?)?.toInt() ?? 0,
      goodCount: (counts['Good'] as num?)?.toInt() ?? 0,
      acceptableCount: (counts['Acceptable'] as num?)?.toInt() ?? 0,
      poorCount: (counts['Poor'] as num?)?.toInt() ?? 0,
      totalEvaluated: (map['totalEvaluated'] as num?)?.toInt() ?? 0,
      averageScore: (map['averageScore'] as num?)?.toDouble() ?? 0,
      performance: map['performance'] as String? ?? '',
    );
  }
}
