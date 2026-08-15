import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:permission_handler/permission_handler.dart';

import 'student_code_ble_protocol.dart';

final StreamController<String> _debugLogController =
    StreamController<String>.broadcast();

void _log(String message) {
  debugPrint('[BLE:StudentCodeAdv] $message');
  if (!_debugLogController.isClosed) _debugLogController.add(message);
}

/// Student-side advertiser for the Live Co-Sign BLE protocol: broadcasts
/// this procedure's co-sign code so the supervisor's
/// [SupervisorCodeBleScanner] can pick it up and drive the actual co-sign
/// call from the supervisor's device.
///
/// Deliberately narrow: only manages permissions/Bluetooth state and the
/// advertised bytes. Never calls the co-sign API and never decides
/// authorization — that happens on the supervisor's device via
/// `CoSignProcedureUseCase`, triggered by a human tap in `CoSignCodeSheet`,
/// once it receives the code.
///
/// No session-token rotation: a co-sign code is static for its whole
/// server-side lifetime, so the same bytes are advertised for the entire
/// (short, [kStudentCodeAdvertiseWindow]-bounded) advertising window.
abstract class StudentCodeBleAdvertiser {
  Future<bool> hasRequiredPermissions();
  Future<bool> requestRequiredPermissions();

  /// True if this device supports BLE peripheral (advertiser) mode and its
  /// Bluetooth radio is currently on.
  Future<bool> isReady();

  /// Starts advertising [coSignCode] (must be a 32-hex-char string — see
  /// [coSignCodeToBytes]). Returns whether advertising actually started.
  Future<bool> start(String coSignCode);

  /// Stops advertising. Safe to call when already stopped (no-op).
  Future<void> stop();
  Future<void> dispose();
  bool get isAdvertising;

  /// Live feed of diagnostic lines, for the debug screen — mirrors the
  /// pattern used by the rest of the app's BLE tooling.
  Stream<String> get debugLog;
}

class StudentCodeBleAdvertiserImpl implements StudentCodeBleAdvertiser {
  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();

  bool _isAdvertising = false;

  static const List<Permission> _blePermissions = [
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
  ];

  @override
  Stream<String> get debugLog => _debugLogController.stream;

  @override
  bool get isAdvertising => _isAdvertising;

  @override
  Future<bool> hasRequiredPermissions() async {
    final statuses = await Future.wait(_blePermissions.map((p) => p.status));
    return statuses.every((s) => s.isGranted || s.isLimited);
  }

  @override
  Future<bool> requestRequiredPermissions() async {
    final statuses = await _blePermissions.request();
    return statuses.values.every((s) => s.isGranted || s.isLimited);
  }

  @override
  Future<bool> isReady() async {
    final supported = await _peripheral.isSupported;
    if (!supported) return false;
    return _peripheral.isBluetoothOn;
  }

  @override
  Future<bool> start(String coSignCode) async {
    _log('start: requested');

    // CHANGE 1: Always stop any previous session first so we never leak slots
    await stop();

    final codeBytes = coSignCodeToBytes(coSignCode);
    if (codeBytes == null) {
      _log('start: malformed coSignCode, refusing to advertise');
      return false;
    }

    final permitted = await requestRequiredPermissions();
    _log('start: permissions granted=$permitted');
    if (!permitted) return false;

    final ready = await isReady();
    _log('start: peripheral ready=$ready');
    if (!ready) return false;

    for (final delayMs in [0, 900]) {
      if (delayMs > 0) {
        _log('start: retrying after ${delayMs}ms backoff');
        await Future.delayed(Duration(milliseconds: delayMs));
      }
      if (await _advertise(codeBytes)) return true;
    }
    return false;
  }

  @override
  Future<void> stop() async {
    // CHANGE 2: Optimistically set state to false immediately to prevent race conditions
    _isAdvertising = false;
    try {
      // Force an explicit call to stop on the native peripheral to free slot
      _log('stop: stopping advertising hardware slot');
      await _peripheral.stop();
    } catch (e) {
      _log('stop: threw $e');
    }
  }

  // CHANGE 3: Add dispose method for widget/controller teardown
  @override
  Future<void> dispose() async {
    _log('dispose: cleaning up advertiser resources');
    await stop();
  }

  Future<bool> _advertise(Uint8List codeBytes) async {
    // Single packet, no scan-response split — this plugin's `start()` has a
    // known bug where splitting advertiseData/advertiseResponseData across
    // packets crashes on Android (the response-data JSON gets built from
    // advertiseData again instead), so the whole payload has to fit one
    // packet. Channel split is by field, not by packet: Android reads
    // manufacturerId/manufacturerData, iOS reads serviceUuids.
    final codeUuid = payloadBytesToUuidString(codeBytes);
    final data = AdvertiseData(
      manufacturerId: kAnesTrackManufacturerId,
      manufacturerData: codeBytes,
      serviceUuids: [kAnesTrackServiceUuid, codeUuid],
    );

    // The plugin's AdvertiseSettings default is TX_POWER_LOW (short-range)
    // and advertiseSet:true (routes through Android's newer Advertising Set
    // API, which is invisible to a scanner using legacy scanForDevices and
    // fails outright on some older chipsets with
    // ADVERTISE_FAILED_TOO_MANY_ADVERTISERS due to limited hardware
    // advertising-set slots). Force high power + legacy path.
    final settings = AdvertiseSettings(
      advertiseSet: false,
      txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh,
      advertiseMode: AdvertiseMode.advertiseModeLowLatency,
    );

    try {
      await _peripheral.stop();
    } catch (_) {
      // No-op: nothing to stop, or the platform already cleared it.
    }
    // Give the platform a moment to actually release the just-stopped
    // registration before asking for a new one — mirrors the settle delay
    // used after start() below, but on the way in.
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final state = await _peripheral.start(
        advertiseData: data,
        advertiseSettings: settings,
      );
      _log(
        'advertise: start() returned state=$state (not authoritative — see below)',
      );
    } catch (e) {
      _log('advertise: threw $e');
      return false;
    }

    // start()'s return value isn't authoritative: this plugin's Android
    // implementation can resolve the platform-channel result with a stale
    // value before the real AdvertiseCallback.onStartSuccess/onStartFailure
    // fires. `isAdvertising` reflects the callback's actual outcome, so give
    // it a moment to land before checking.
    await Future.delayed(const Duration(milliseconds: 700));
    final reallyAdvertising = await _peripheral.isAdvertising;
    _log('advertise: isAdvertising=$reallyAdvertising');
    _isAdvertising = reallyAdvertising;
    return reallyAdvertising;
  }
}
