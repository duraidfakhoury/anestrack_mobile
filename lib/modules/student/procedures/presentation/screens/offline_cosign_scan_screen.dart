import 'dart:async';

import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_cosign_qr_payload.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

const _teal = Color(0xFF0D9488);
const _cyan = Color(0xFF0891B2);

/// Student — scans the supervisor's bedside QR (offline co-sign). Pops the
/// decoded [OfflineCoSignQrPayload] back to the caller on success, or `null`
/// if the student backs out.
///
/// QR-only, deliberately with NO manual-entry, paste, or share-sheet
/// fallback (spec rule §8.1) — unlike the *online* live co-sign flow's
/// `CoSignScanScreen`/`CoSignCodeSheet`, which allows typing a code in,
/// because that flow's code isn't standing in as bedside-proximity
/// evidence the way this one is.
class OfflineCoSignScanScreen extends StatefulWidget {
  const OfflineCoSignScanScreen({super.key});

  @override
  State<OfflineCoSignScanScreen> createState() =>
      _OfflineCoSignScanScreenState();
}

class _OfflineCoSignScanScreenState extends State<OfflineCoSignScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();

  OfflineCoSignQrPayload? _captured;
  String? _errorMessage;

  void _onDetect(BarcodeCapture capture) {
    if (_captured != null) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    final decoded = OfflineCoSignQrDecodeResult.decode(raw);
    switch (decoded.status) {
      case OfflineCoSignQrDecodeStatus.success:
        unawaited(_scannerController.stop());
        setState(() {
          _captured = decoded.payload;
          _errorMessage = null;
        });
      case OfflineCoSignQrDecodeStatus.invalidFormat:
        setState(() {
          _errorMessage = LocaleKeys.offline_cosign_scan_invalid_qr.tr();
        });
      case OfflineCoSignQrDecodeStatus.unsupportedVersion:
        setState(() {
          _errorMessage =
              LocaleKeys.offline_cosign_scan_unsupported_version.tr();
        });
    }
  }

  void _rescan() {
    setState(() {
      _captured = null;
      _errorMessage = null;
    });
    unawaited(_scannerController.start());
  }

  void _confirm() {
    if (_captured != null) context.pop(_captured);
  }

  /// Advisory only — never blocks confirming the scan (spec §3: informational,
  /// so the student can catch a wrong clock before syncing; real enforcement
  /// is server-side scoring via the `capturedAt` clamp, spec §7).
  int? get _clockSkewMinutes {
    final witnessedAt = _captured?.witnessedAtDate;
    if (witnessedAt == null) return null;
    return DateTime.now().toUtc().difference(witnessedAt).inMinutes.abs();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(
            child: _captured != null ? _buildConfirmBody() : _buildScanBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 22, right: 20, left: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_teal, _cyan],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowRight, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.offline_cosign_scan_title.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LocaleKeys.offline_cosign_scan_subtitle.tr(),
                  style: const TextStyle(
                    color: Color(0xFFCFFAFE),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: MobileScanner(
                controller: _scannerController,
                onDetect: _onDetect,
              ),
            ),
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEDEC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF2C6C2)),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.triangleAlert,
                    size: 16,
                    color: Color(0xFFC1483F),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFFC1483F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConfirmBody() {
    final skew = _clockSkewMinutes;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3EAED)),
            ),
            child: Column(
              children: [
                const Icon(
                  LucideIcons.circleCheck,
                  color: Color(0xFF2E9E6B),
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  LocaleKeys.offline_cosign_scan_captured_title.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          if (skew != null && skew >= 5) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF4E7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3DCB5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.clockAlert,
                    color: Color(0xFFD98C2B),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      LocaleKeys.offline_cosign_scan_clock_skew_warning.tr(
                        args: [skew.toString()],
                      ),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(LocaleKeys.offline_cosign_scan_confirm_button.tr()),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _rescan,
            style: OutlinedButton.styleFrom(
              foregroundColor: _teal,
              side: const BorderSide(color: Color(0xFFCFE6E8)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(LocaleKeys.offline_cosign_scan_rescan_button.tr()),
          ),
        ],
      ),
    );
  }
}
