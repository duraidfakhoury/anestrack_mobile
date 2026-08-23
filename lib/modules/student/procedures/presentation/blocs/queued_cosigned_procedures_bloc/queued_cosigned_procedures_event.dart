import 'package:equatable/equatable.dart';

sealed class QueuedCosignedProceduresEvent extends Equatable {
  const QueuedCosignedProceduresEvent();
}

class FetchQueuedCosignedProceduresEvent extends QueuedCosignedProceduresEvent {
  const FetchQueuedCosignedProceduresEvent();

  @override
  List<Object?> get props => [];
}

/// Re-fetches the queue, e.g. after a new item is queued or after a sync
/// run finishes (see `OfflineCosignedProcedureSyncService`).
class RefreshQueuedCosignedProceduresEvent extends QueuedCosignedProceduresEvent {
  const RefreshQueuedCosignedProceduresEvent();

  @override
  List<Object?> get props => [];
}
