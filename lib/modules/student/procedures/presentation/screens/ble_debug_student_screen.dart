import 'dart:async';
import 'dart:math';

import 'package:anestrack_mobile/core/services/ble/student_code_ble_advertiser.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _indigo = Color(0xFF4338CA);

/// Debug-only tool for the student side of Live Co-Sign: advertises a
/// (real or generated test) co-sign code and shows a live log, so BLE
/// issues can be diagnosed without a terminal attached.
class BleDebugStudentScreen extends StatefulWidget {
  const BleDebugStudentScreen({super.key});

  @override
  State<BleDebugStudentScreen> createState() => _BleDebugStudentScreenState();
}

class _BleDebugStudentScreenState extends State<BleDebugStudentScreen> {
  final StudentCodeBleAdvertiser _codeAdvertiser = sl<StudentCodeBleAdvertiser>();
  final List<String> _log = [];
  final TextEditingController _codeController = TextEditingController();

  StreamSubscription<String>? _codeAdvLogSubscription;
  bool _advertisingCode = false;
  bool _codeAdvBusy = false;

  @override
  void initState() {
    super.initState();
    _codeAdvLogSubscription = _codeAdvertiser.debugLog.listen((line) {
      if (!mounted) return;
      setState(() => _log.insert(0, line));
    });
  }

  @override
  void dispose() {
    _codeAdvLogSubscription?.cancel();
    _codeController.dispose();
    if (_advertisingCode) unawaited(_codeAdvertiser.stop());
    super.dispose();
  }

  String _generateTestCode() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<void> _toggleCodeAdvertising() async {
    setState(() => _codeAdvBusy = true);
    if (_advertisingCode) {
      await _codeAdvertiser.stop();
      if (!mounted) return;
      setState(() {
        _advertisingCode = false;
        _codeAdvBusy = false;
      });
      return;
    }

    if (_codeController.text.trim().isEmpty) {
      _codeController.text = _generateTestCode();
    }
    final started = await _codeAdvertiser.start(_codeController.text.trim());
    if (!mounted) return;
    setState(() {
      _advertisingCode = started;
      _codeAdvBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          LocaleKeys.ble_debug_title_student.tr(),
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
            child: _buildCodeAdvertiseCard(),
          ),
          Expanded(child: _buildLogPanel()),
        ],
      ),
    );
  }

  Widget _buildCodeAdvertiseCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _codeController,
            enabled: !_advertisingCode,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            decoration: InputDecoration(
              labelText: LocaleKeys.ble_debug_payload_label.tr(),
              isDense: true,
              suffixIcon: IconButton(
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                onPressed: _advertisingCode
                    ? null
                    : () => setState(
                        () => _codeController.text = _generateTestCode(),
                      ),
                tooltip: LocaleKeys.ble_debug_generate_code.tr(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _codeAdvBusy ? null : _toggleCodeAdvertising,
            style: ElevatedButton.styleFrom(
              backgroundColor: _advertisingCode
                  ? const Color(0xFFC1483F)
                  : _indigo,
              foregroundColor: Colors.white,
            ),
            icon: Icon(
              _advertisingCode ? LucideIcons.circleStop : LucideIcons.send,
              size: 16,
            ),
            label: Text(
              _advertisingCode
                  ? LocaleKeys.ble_debug_stop_advertising.tr()
                  : LocaleKeys.ble_debug_start_advertising.tr(),
            ),
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
