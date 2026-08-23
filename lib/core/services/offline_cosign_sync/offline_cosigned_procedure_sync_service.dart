import 'dart:async';

import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/services/connectivity/connectivity_service.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/modules/common/offline_cosign_status/presentation/blocs/offline_cosign_status_bloc/offline_cosign_status_bloc.dart';
import 'package:anestrack_mobile/modules/common/offline_cosign_status/presentation/blocs/offline_cosign_status_bloc/offline_cosign_status_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/sync_offline_cosigned_procedures_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/queued_cosigned_procedures_bloc/queued_cosigned_procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/queued_cosigned_procedures_bloc/queued_cosigned_procedures_event.dart';

/// Student — background trigger that drains the offline co-signed-procedure
/// queue (`syncOfflineCoSignedProcedures`) whenever connectivity comes back.
/// Mirrors `ProcedureSyncService`'s connectivity-transition + periodic-timer
/// + explicit-`syncNow()` pattern exactly, but for the separate co-sign
/// queue (spec §10: kept isolated from the plain offline queue).
abstract class OfflineCosignedProcedureSyncService {
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
  Future<void> syncNow();
}

class OfflineCosignedProcedureSyncServiceImpl
    implements OfflineCosignedProcedureSyncService {
  final ConnectivityService connectivityService;
  final SyncOfflineCoSignedProceduresUseCase syncOfflineCoSignedProceduresUseCase;
  final Logger _logger = Logger();

  // Same reasoning as ProcedureSyncService: connectivity_plus reports
  // link-layer status only, so a periodic retry is the safety net for a
  // connection that stays "attached" but never actually completes requests.
  static const Duration _retryInterval = Duration(minutes: 3);

  StreamSubscription<bool>? _subscription;
  Timer? _periodicTimer;
  bool _syncing = false;

  OfflineCosignedProcedureSyncServiceImpl(
    this.connectivityService,
    this.syncOfflineCoSignedProceduresUseCase,
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
      final result = await syncOfflineCoSignedProceduresUseCase();
      result.fold(
        (failure) => _logger.e(
          "Offline co-signed procedure sync run failed: ${failure.message}",
        ),
        (r) {
          _logger.i(
            "Offline co-signed procedure sync run: succeeded=${r.successCount} "
            "failed=${r.failureCount} coSigned=${r.coSignedCount} "
            "pending=${r.pendingCount} stoppedEarlyOffline=${r.stoppedEarlyOffline}",
          );
          if (r.successCount > 0) {
            // Synced items became real procedures server-side.
            sl<ProceduresBloc>().add(const RefreshProceduresEvent());
          }
          if (r.hadWork) {
            sl<QueuedCosignedProceduresBloc>().add(
              const RefreshQueuedCosignedProceduresEvent(),
            );
            sl<OfflineCoSignStatusBloc>().add(
              const RefreshOfflineCoSignStatusEvent(),
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
