import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import 'student_code_ble_protocol.dart';

final StreamController<String> _debugLogController =
    StreamController<String>.broadcast();

void _log(String message) {
  debugPrint('[BLE:SupervisorCodeScan] $message');
  if (!_debugLogController.isClosed) _debugLogController.add(message);
}

/// A decoded, nearby student co-sign code broadcast. This is purely a
/// **local BLE receive** signal — "a device advertising this exact code was
/// nearby". It carries no authorization by itself; the supervisor must
/// still tap to confirm in `CoSignCodeSheet`, which drives the real
/// authorization boundary via `CoSignProcedureUseCase`.
class StudentCodeDetection {
  final String coSignCode;
  final int rssi;

  const StudentCodeDetection({required this.coSignCode, required this.rssi});
}

/// Supervisor-side scanner for the Live Co-Sign BLE protocol: while "Live
/// Co-Sign" is toggled on (see `LiveCoSignBloc`), this scans for a nearby
/// student's co-sign code broadcast (from `StudentCodeBleAdvertiser`).
///
/// Deliberately narrow: permissions, Bluetooth state, scanning, and
/// decoding only. Never calls the co-sign API and never decides
/// authorization — a detected code only surfaces for the UI to open
/// `CoSignCodeSheet`, where a human confirms.
abstract class SupervisorCodeBleScanner {
  Future<bool> hasRequiredPermissions();
  Future<bool> requestRequiredPermissions();

  Stream<StudentCodeDetection> startScanning({int minRssi = kDefaultMinRssi});

  Future<void> stopScanning();
  Future<void> dispose();

  Stream<String> get debugLog;
}

class SupervisorCodeBleScannerImpl implements SupervisorCodeBleScanner {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamController<StudentCodeDetection>? _scanController;

  static const List<Permission> _blePermissions = [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
  ];
  static const Permission _legacyLocationPermission =
      Permission.locationWhenInUse;

  @override
  Stream<String> get debugLog => _debugLogController.stream;

  @override
  Future<bool> hasRequiredPermissions() async {
    final statuses = await Future.wait(_blePermissions.map((p) => p.status));
    return statuses.every((s) => s.isGranted || s.isLimited);
  }

  @override
  Future<bool> requestRequiredPermissions() async {
    final statuses = await _blePermissions.request();
    if (!statuses.values.every((s) => s.isGranted || s.isLimited)) {
      return false;
    }
    await _legacyLocationPermission.request();
    return true;
  }

  @override
  Stream<StudentCodeDetection> startScanning({
    int minRssi = kDefaultMinRssi,
  }) {
    _log('startScanning: requested (minRssi=$minRssi)');

    // 1. Clean up any existing scan subscription and controller safely first
    _cleanupScanResources();

    late final StreamController<StudentCodeDetection> controller;
    controller = StreamController<StudentCodeDetection>.broadcast(
      onCancel: () {
        // Guard against a stale controller — one already superseded by a
        // newer startScanning() call — re-entering stopScanning() and
        // tearing down a session it no longer owns.
        if (identical(_scanController, controller)) {
          unawaited(stopScanning());
        }
      },
    );
    _scanController = controller;

    _startScanInternal(controller, minRssi);

    return controller.stream;
  }

  // ... keep _startScanInternal, _handleDiscovery, _tryDecodeCode, and _maskCode as is ...

  // 2. Add dedicated cleanup method for scan resources
  void _cleanupScanResources() {
    final oldSubscription = _scanSubscription;
    final oldController = _scanController;
    _scanSubscription = null;
    _scanController = null;

    unawaited(oldSubscription?.cancel());
    if (oldController != null && !oldController.isClosed) {
      unawaited(oldController.close());
    }
  }

  // 3. Update stopScanning to use the clean teardown helper
  @override
  Future<void> stopScanning() async {
    _log('stopScanning');
    _cleanupScanResources();
  }

  // 4. Implement dispose for lifecycle management
  @override
  Future<void> dispose() async {
    _log('dispose: cleaning up supervisor scanner resources');
    await stopScanning();
  }

  Future<void> _startScanInternal(
    StreamController<StudentCodeDetection> controller,
    int minRssi,
  ) async {
    final permitted = await hasRequiredPermissions();
    _log('startScanning: permissions granted=$permitted');
    if (!permitted) {
      controller.addError(StateError('Bluetooth permission not granted.'));
      return;
    }

    final status = await _ble.statusStream
        .firstWhere((s) => s != BleStatus.unknown)
        .timeout(const Duration(seconds: 3), onTimeout: () => _ble.status);
    _log('startScanning: adapter status=$status');
    if (status != BleStatus.ready) {
      controller.addError(
        StateError('Bluetooth adapter or Location service is disabled.'),
      );
      return;
    }

    if (!identical(_scanController, controller)) {
      _log('startScanning: superseded before subscribing, aborting');
      try {
        controller.addError(
          StateError('Scan attempt superseded before it could start.'),
        );
      } catch (_) {
        // Already closed by whatever superseded this attempt — nothing to
        // notify.
      }
      return;
    }

    // Not filtering by withServices, since the Android delivery channel
    // carries no filterable service UUID (manufacturer data only) —
    // matching is done in Dart via [_tryDecodeCode], gated on the AnesTrack
    // manufacturer ID / marker service UUID.
    _log('startScanning: subscribing (broad scan, matching done in Dart)');
    _scanSubscription = _ble
        .scanForDevices(
          withServices: const [],
          scanMode: ScanMode.lowLatency,
          requireLocationServicesEnabled: false,
        )
        .listen(
          (device) => _handleDiscovery(device, controller, minRssi),
          onError: (error) {
            _log('startScanning: stream error=$error');
            if (!controller.isClosed) controller.addError(error);
          },
        );
  }

  void _handleDiscovery(
    DiscoveredDevice device,
    StreamController<StudentCodeDetection> controller,
    int minRssi,
  ) {
    _log(
      'seen device id=${device.id} rssi=${device.rssi} '
      'manufacturerDataLen=${device.manufacturerData.length} '
      'serviceUuids=${device.serviceUuids}',
    );
    final code = _tryDecodeCode(device);
    if (code == null) return;

    if (device.rssi < minRssi) {
      _log('reject: rssi=${device.rssi} below floor=$minRssi');
      return;
    }

    _log('MATCH: coSignCode=${_maskCode(code)} rssi=${device.rssi}');
    if (!controller.isClosed) {
      controller.add(StudentCodeDetection(coSignCode: code, rssi: device.rssi));
    }
  }

  /// Two delivery channels, mirroring `StudentCodeBleAdvertiserImpl`:
  /// Android manufacturer data (tagged with [kAnesTrackManufacturerId]) or a
  /// dynamic service UUID alongside the static [kAnesTrackServiceUuid]
  /// marker (iOS). Both branches actively verify the AnesTrack marker rather
  /// than just checking byte length, to avoid matching any nearby unrelated
  /// device's manufacturer payload or service UUID as if it were a valid
  /// code — confirmed necessary in practice: an unrelated nearby device
  /// whose manufacturer data happened to be exactly 16 bytes was previously
  /// misdecoded as a "valid" code by a since-removed length-only fallback
  /// path that assumed some chipsets strip the company-ID prefix. That
  /// fallback had no way to verify the AnesTrack marker at all, so it's
  /// gone — `flutter_reactive_ble`'s Android implementation always reports
  /// the 2-byte company-ID prefix intact (see `ManufacturerDataConverter.kt`
  /// upstream), so the length+2 branch below is sufficient on Android; iOS
  /// relies solely on the service-UUID branch since its peripheral mode
  /// can't send manufacturer data at all.
  String? _tryDecodeCode(DiscoveredDevice device) {
    final mData = device.manufacturerData;
    if (mData.length == kPayloadLength + 2) {
      // Manufacturer-specific-data AD structure = 2-byte company ID
      // (little-endian) + payload. Only accept it if the ID actually
      // matches ours.
      final manufacturerId = mData[0] | (mData[1] << 8);
      if (manufacturerId == kAnesTrackManufacturerId) {
        return coSignCodeFromBytes(mData.sublist(2));
      }
    }

    final serviceUuids = device.serviceUuids.map(
      (u) => u.toString().toLowerCase(),
    );
    if (serviceUuids.contains(kAnesTrackServiceUuid.toLowerCase())) {
      for (final uuid in serviceUuids) {
        if (uuid == kAnesTrackServiceUuid.toLowerCase()) continue;
        final bytes = payloadBytesFromUuidString(uuid);
        if (bytes != null) return coSignCodeFromBytes(bytes);
      }
    }

    return null;
  }

  static String _maskCode(String code) {
    if (code.length <= 4) return '***';
    return '${code.substring(0, 4)}***';
  }
}
