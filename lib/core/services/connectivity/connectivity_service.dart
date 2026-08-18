import 'package:connectivity_plus/connectivity_plus.dart';

/// Device-level network connectivity detection. Reports link-layer status
/// (wifi/cellular attached), not true backend reachability — it must only
/// ever be used as a **trigger** to attempt work, never as the authority on
/// whether a request actually succeeded (that's decided by the real HTTP
/// call's resulting failure type).
abstract class ConnectivityService {
  Future<bool> isOnline();

  /// Emits on every connectivity transition (deduped).
  Stream<bool> get onConnectivityChanged;
}

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none))
      .distinct();
}
