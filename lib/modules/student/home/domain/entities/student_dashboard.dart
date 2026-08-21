import 'package:equatable/equatable.dart';

/// A procedure-type row from `byProcedureType`, e.g. {"تخدير عام": 4}.
class ProcedureTypeCount extends Equatable {
  final String procedureTypeId;
  final String name;
  final int count;

  const ProcedureTypeCount({
    required this.procedureTypeId,
    required this.name,
    required this.count,
  });

  @override
  List<Object?> get props => [procedureTypeId, name, count];
}

/// Breakdown of the student's procedure evaluations, from the `evaluation`
/// object in the `getStudentDashboard` response.
class StudentEvaluationSummary extends Equatable {
  final int excellentCount;
  final int goodCount;
  final int acceptableCount;
  final int poorCount;
  final int totalEvaluated;
  final double averageScore;
  final String performance;

  const StudentEvaluationSummary({
    required this.excellentCount,
    required this.goodCount,
    required this.acceptableCount,
    required this.poorCount,
    required this.totalEvaluated,
    required this.averageScore,
    required this.performance,
  });

  @override
  List<Object?> get props => [
    excellentCount,
    goodCount,
    acceptableCount,
    poorCount,
    totalEvaluated,
    averageScore,
    performance,
  ];
}

/// Student home-dashboard stats, returned by the backend
/// `getStudentDashboard` cloud function.
class StudentDashboardStats extends Equatable {
  final int totalProcedures;
  final int pendingProcedures;
  final int approvedProcedures;
  final int rejectedProcedures;
  final List<ProcedureTypeCount> byProcedureType;
  final StudentEvaluationSummary evaluation;

  const StudentDashboardStats({
    required this.totalProcedures,
    required this.pendingProcedures,
    required this.approvedProcedures,
    required this.rejectedProcedures,
    required this.byProcedureType,
    required this.evaluation,
  });

  @override
  List<Object?> get props => [
    totalProcedures,
    pendingProcedures,
    approvedProcedures,
    rejectedProcedures,
    byProcedureType,
    evaluation,
  ];
}
