import 'dart:async';

import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/services/connectivity/connectivity_service.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/modules/common/offline_cosign_status/presentation/blocs/offline_cosign_status_bloc/offline_cosign_status_bloc.dart';
import 'package:anestrack_mobile/modules/common/offline_cosign_status/presentation/blocs/offline_cosign_status_bloc/offline_cosign_status_event.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/domain/usecases/submit_offline_attestations_usecase.dart';

/// Supervisor — background trigger that drains the local attestation outbox
/// (`submitOfflineAttestations`) whenever connectivity comes back. Mirrors
/// `ProcedureSyncService`'s connectivity-transition + periodic-timer +
/// explicit-`syncNow()` pattern exactly, but for the supervisor-only
/// attestation outbox.
abstract class OfflineAttestationSyncService {
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
  Future<void> syncNow();
}

class OfflineAttestationSyncServiceImpl implements OfflineAttestationSyncService {
  final ConnectivityService connectivityService;
  final SubmitOfflineAttestationsUseCase submitOfflineAttestationsUseCase;
  final Logger _logger = Logger();

  // Same reasoning as ProcedureSyncService: connectivity_plus reports
  // link-layer status only, so a periodic retry is the safety net for a
  // connection that stays "attached" but never actually completes requests.
  static const Duration _retryInterval = Duration(minutes: 3);

  StreamSubscription<bool>? _subscription;
  Timer? _periodicTimer;
  bool _syncing = false;

  OfflineAttestationSyncServiceImpl(
    this.connectivityService,
    this.submitOfflineAttestationsUseCase,
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
      final result = await submitOfflineAttestationsUseCase();
      result.fold(
        (failure) => _logger.e(
          "Offline attestation submit run failed: ${failure.message}",
        ),
        (r) {
          _logger.i(
            "Offline attestation submit run: succeeded=${r.successCount} "
            "failed=${r.failureCount} matched=${r.matchedCount} "
            "stoppedEarlyOffline=${r.stoppedEarlyOffline}",
          );
          if (r.hadWork) {
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
