part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

/// Fetches (or refetches) the dashboard, optionally scoped to a hospital.
/// `hospitalId == null` means "all hospitals".
class FetchDashboardEvent extends DashboardEvent {
  final String? hospitalId;

  FetchDashboardEvent([this.hospitalId]);
}
