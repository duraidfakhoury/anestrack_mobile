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

/// Supervisor home-dashboard stats, returned by the backend
/// `getSupervisorDashboard` cloud function.
class SupervisorDashboardStats extends Equatable {
  final int totalProcedures;
  final int approvedProcedures;
  final int rejectedProcedures;
  final int pendingReview;
  final int totalStudents;
  final List<ProcedureTypeCount> byProcedureType;

  const SupervisorDashboardStats({
    required this.totalProcedures,
    required this.approvedProcedures,
    required this.rejectedProcedures,
    required this.pendingReview,
    required this.totalStudents,
    required this.byProcedureType,
  });

  @override
  List<Object?> get props => [
    totalProcedures,
    approvedProcedures,
    rejectedProcedures,
    pendingReview,
    totalStudents,
    byProcedureType,
  ];
}
