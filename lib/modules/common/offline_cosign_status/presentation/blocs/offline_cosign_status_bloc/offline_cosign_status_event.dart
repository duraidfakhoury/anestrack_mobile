import 'package:equatable/equatable.dart';

sealed class OfflineCoSignStatusEvent extends Equatable {
  const OfflineCoSignStatusEvent();
}

class FetchOfflineCoSignStatusEvent extends OfflineCoSignStatusEvent {
  const FetchOfflineCoSignStatusEvent();

  @override
  List<Object?> get props => [];
}

/// Re-fetches, e.g. after a sync run finishes (see
/// `OfflineCosignedProcedureSyncService` / `OfflineAttestationSyncService`).
class RefreshOfflineCoSignStatusEvent extends OfflineCoSignStatusEvent {
  const RefreshOfflineCoSignStatusEvent();

  @override
  List<Object?> get props => [];
}
