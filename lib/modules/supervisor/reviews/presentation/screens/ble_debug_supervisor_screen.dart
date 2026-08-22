import 'dart:async';

import 'package:anestrack_mobile/core/services/ble/supervisor_code_ble_scanner.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _teal = Color(0xFF0D9488);

class _CodeCandidate {
  final String coSignCode;
  int rssi;
  DateTime lastSeen;

  _CodeCandidate({
    required this.coSignCode,
    required this.rssi,
    required this.lastSeen,
  });
}

/// Debug-only tool for the supervisor side of Live Co-Sign: toggles
/// scanning directly (bypassing the reviews screen's "Live Co-Sign" switch)
/// and lists every distinct nearby student co-sign code detected, with a
/// live log, so BLE issues can be diagnosed without a terminal attached.
class BleDebugSupervisorScreen extends StatefulWidget {
  const BleDebugSupervisorScreen({super.key});

  @override
  State<BleDebugSupervisorScreen> createState() =>
      _BleDebugSupervisorScreenState();
}

class _BleDebugSupervisorScreenState extends State<BleDebugSupervisorScreen> {
  final SupervisorCodeBleScanner _codeScanner = sl<SupervisorCodeBleScanner>();
  final List<String> _log = [];
  final Map<String, _CodeCandidate> _codeCandidates = {};
  StreamSubscription<String>? _codeScanLogSubscription;
  StreamSubscription<StudentCodeDetection>? _codeScanSubscription;

  bool _scanningCodes = false;

  /// True while a start/stop request is settling. The scanner's startup
  /// checks (permissions, adapter status) can take a few seconds; blocking
  /// the button during that window stops a fast re-tap from racing the
  /// in-flight start and silently killing it before it ever subscribes.
  bool _busy = false;

  static const _scanSetupGuard = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _codeScanLogSubscription = _codeScanner.debugLog.listen((line) {
      if (!mounted) return;
      setState(() => _log.insert(0, line));
    });
  }

  @override
  void dispose() {
    _codeScanLogSubscription?.cancel();
    _codeScanSubscription?.cancel();
    if (_scanningCodes) unawaited(_codeScanner.stopScanning());
    super.dispose();
  }

  void _onScanError(Object error) {
    if (!mounted) return;
    setState(() {
      _scanningCodes = false;
      _busy = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('BLE scan error: $error')));
  }

  Future<void> _toggleCodeScanning() async {
    if (_busy) return;

    if (_scanningCodes) {
      setState(() => _busy = true);
      await _codeScanSubscription?.cancel();
      _codeScanSubscription = null;
      await _codeScanner.stopScanning();
      if (!mounted) return;
      setState(() {
        _scanningCodes = false;
        _busy = false;
      });
      return;
    }

    setState(() {
      _scanningCodes = true;
      _busy = true;
      _codeCandidates.clear();
    });
    _codeScanSubscription = _codeScanner.startScanning().listen(
      (detection) {
        if (!mounted) return;
        setState(() {
          _codeCandidates[detection.coSignCode] = _CodeCandidate(
            coSignCode: detection.coSignCode,
            rssi: detection.rssi,
            lastSeen: DateTime.now(),
          );
        });
      },
      onError: _onScanError,
    );

    await Future.delayed(_scanSetupGuard);
    if (!mounted || !_scanningCodes) return;
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          LocaleKeys.ble_debug_title_supervisor.tr(),
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowRight, color: Color(0xFF374151)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _busy ? null : _toggleCodeScanning,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _scanningCodes
                        ? const Color(0xFFC1483F)
                        : _teal,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(
                    _scanningCodes
                        ? LucideIcons.circleStop
                        : LucideIcons.bluetooth,
                    size: 16,
                  ),
                  label: Text(
                    _scanningCodes
                        ? LocaleKeys.ble_debug_stop_scanning.tr()
                        : LocaleKeys.ble_debug_start_scanning.tr(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              LocaleKeys.ble_debug_candidates_label.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: _codeCandidates.isEmpty
                ? Center(
                    child: Text(
                      LocaleKeys.ble_debug_no_candidates.tr(),
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: (_codeCandidates.values.toList()
                          ..sort((a, b) => b.rssi.compareTo(a.rssi)))
                        .map(_buildCodeCandidateCard)
                        .toList(),
                  ),
          ),
          Expanded(child: _buildLogPanel()),
        ],
      ),
    );
  }

  Widget _buildCodeCandidateCard(_CodeCandidate candidate) {
    final secondsAgo = DateTime.now().difference(candidate.lastSeen).inSeconds;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'coSignCode=${candidate.coSignCode}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'rssi=${candidate.rssi}  •  ${secondsAgo}s ago',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3EAED)),
      ),
      child: Row(
        children: [
          Icon(
            _scanningCodes ? LucideIcons.bluetooth : LucideIcons.bluetoothOff,
            size: 16,
            color: _scanningCodes ? _teal : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 6),
          Text(
            '${LocaleKeys.ble_debug_status_label.tr()}: '
            '${_scanningCodes ? "scanning" : "idle"}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLogPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                LocaleKeys.ble_debug_log_label.tr(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(_log.clear),
                child: Text(
                  LocaleKeys.ble_debug_clear_log.tr(),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _log.length,
              itemBuilder: (context, index) => Text(
                _log[index],
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
