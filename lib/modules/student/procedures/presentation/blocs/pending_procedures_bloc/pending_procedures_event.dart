import 'package:equatable/equatable.dart';

sealed class PendingProceduresEvent extends Equatable {
  const PendingProceduresEvent();
}

class FetchPendingProceduresEvent extends PendingProceduresEvent {
  const FetchPendingProceduresEvent();

  @override
  List<Object?> get props => [];
}

/// Re-fetches the queue, e.g. after a new item is queued or after a sync
/// run finishes (see `ProcedureSyncService`).
class RefreshPendingProceduresEvent extends PendingProceduresEvent {
  const RefreshPendingProceduresEvent();

  @override
  List<Object?> get props => [];
}
