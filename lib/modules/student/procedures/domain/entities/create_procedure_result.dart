import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';

/// The result of logging a procedure. When the student requested a live co-sign
/// (Flow 1), the backend returns a one-time [coSignCode] alongside the procedure.
/// The code is the shared secret carried phone-to-phone to the supervisor.
class CreateProcedureResult extends Equatable {
  final Procedure procedure;

  /// Present ONLY when `requestLiveCoSign: true` was sent. This is the single
  /// time the code is ever returned — it must be handed to the supervisor
  /// (over BLE/QR/manual) before the 10-minute window lapses.
  final String? coSignCode;

  /// True when the device was offline at submission time and this procedure
  /// was saved locally instead of sent — see `CreateProcedureBloc` and
  /// `ProcedureSyncService`. [procedure] is a local placeholder in that case,
  /// not a server-confirmed record.
  final bool queuedOffline;

  /// True when the submit attempt just failed with `NoInternetFailure` and
  /// nothing has been queued yet — the UI must show the "you're offline —
  /// attach your supervisor's code?" prompt (see
  /// `integration-mobile-offline-cosign.md` §5) and dispatch either
  /// `QueuePlainOfflineProcedureEvent` or `QueueCoSignedOfflineProcedureEvent`
  /// based on the student's choice. [procedure] is a throwaway placeholder
  /// here — nothing has actually been persisted locally yet.
  final bool offlineNeedsDecision;

  /// True when [queuedOffline] is true *and* the student scanned a
  /// supervisor's bedside QR — queued to the co-signed queue
  /// (`syncOfflineCoSignedProcedures`) rather than the plain offline queue.
  final bool queuedCoSigned;

  const CreateProcedureResult({
    required this.procedure,
    this.coSignCode,
    this.queuedOffline = false,
    this.offlineNeedsDecision = false,
    this.queuedCoSigned = false,
  });

  bool get requiresLiveCoSign => coSignCode != null;

  @override
  List<Object?> get props => [
    procedure,
    coSignCode,
    queuedOffline,
    offlineNeedsDecision,
    queuedCoSigned,
  ];
}
