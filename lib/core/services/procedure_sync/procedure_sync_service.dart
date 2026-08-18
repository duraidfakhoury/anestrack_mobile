import 'dart:async';

import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/services/connectivity/connectivity_service.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/sync_pending_procedures_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/pending_procedures_bloc/pending_procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/pending_procedures_bloc/pending_procedures_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_event.dart';

/// Background trigger that drains the offline procedure queue whenever
/// connectivity comes back. Mirrors the BLE services' start/stop/dispose
/// lifecycle pattern (see `lib/core/services/ble/`).
abstract class ProcedureSyncService {
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();

  /// Fires a sync attempt right now, outside the connectivity-transition
  /// trigger. Used for cold-start-with-queue and post-login.
  Future<void> syncNow();
}

class ProcedureSyncServiceImpl implements ProcedureSyncService {
  final ConnectivityService connectivityService;
  final SyncPendingProceduresUseCase syncPendingProceduresUseCase;
  final Logger _logger = Logger();

  // connectivity_plus reports link-layer status (wifi/cellular attached),
  // not real reachability — a connection that stays "attached" but is too
  // poor for requests to complete never fires a transition event. This is
  // the safety net for that case: retry on a timer regardless of whether
  // connectivity ever appeared to change. syncNow()'s own reentrancy guard
  // and the use case's near-instant no-op when the queue is empty keep this
  // cheap.
  static const Duration _retryInterval = Duration(minutes: 3);

  StreamSubscription<bool>? _subscription;
  Timer? _periodicTimer;
  bool _syncing = false;

  ProcedureSyncServiceImpl(
    this.connectivityService,
    this.syncPendingProceduresUseCase,
  );

  @override
  Future<void> start() async {
    await stop();
    _subscription = connectivityService.onConnectivityChanged
        .where((isOnline) => isOnline)
        .listen((_) => syncNow());
    _periodicTimer = Timer.periodic(_retryInterval, (_) => syncNow());
    // Covers cold-start-with-existing-queue: a connectivity *transition*
    // won't fire if the phone was already online when the process launched.
    await syncNow();
  }

  @override
  Future<void> syncNow() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final result = await syncPendingProceduresUseCase();
      result.fold(
        (failure) => _logger.e("Procedure sync run failed: ${failure.message}"),
        (r) {
          _logger.i(
            "Procedure sync run: succeeded=${r.succeededCount} "
            "failed=${r.failedCount} stoppedEarlyOffline=${r.stoppedEarlyOffline}",
          );
          if (r.succeededCount > 0) {
            sl<ProceduresBloc>().add(const RefreshProceduresEvent());
          }
          if (r.hadWork) {
            sl<PendingProceduresBloc>().add(
              const RefreshPendingProceduresEvent(),
            );
          }
        },
      );
    } finally {
      _syncing = false;
    }
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
  }
}
