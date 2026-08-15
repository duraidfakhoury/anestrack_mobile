import 'dart:async';

import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/widgets/co_sign_code_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

const _indigo = Color(0xFF4338CA);
const _indigoLight = Color(0xFF4F46E5);

/// Supervisor QR co-sign entry point: scans the QR code shown on a nearby
/// student's phone (`CoSignHandoffScreen`) and hands it off to
/// [CoSignCodeSheet] for the actual preview (`getCoSignContext`) and
/// co-sign (`coSignProcedure`) work.
///
/// BLE is intentionally NOT scanned here — that happens automatically in
/// the background while "Live Co-Sign" is toggled on (see `LiveCoSignBloc`,
/// toggled from the reviews screen), which surfaces a detected code by
/// opening [CoSignCodeSheet] directly from that screen. This screen remains
/// as the QR/manual fallback path for when a student's BLE code broadcast
/// doesn't get picked up within its advertise window.
///
/// Foreground-only: the camera stops on dispose; no background scanning is
/// implemented.
class CoSignScanScreen extends StatefulWidget {
  const CoSignScanScreen({super.key});

  @override
  State<CoSignScanScreen> createState() => _CoSignScanScreenState();
}

class _CoSignScanScreenState extends State<CoSignScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _handedOff = false;

  void _onQrDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;
    _handleDetection(code);
  }

  Future<void> _handleDetection(String code) async {
    if (_handedOff) return;
    _handedOff = true;
    await _scannerController.stop();
    if (!mounted) return;

    final signed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoSignCodeSheet(
        initialCode: code,
        proximityMethod: 'QR',
      ),
    );

    if (!mounted) return;
    if (signed == true) {
      context.pop(true);
    } else {
      // Detection didn't result in a co-sign (dismissed/error) — resume.
      _handedOff = false;
      unawaited(_scannerController.start());
    }
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
          Expanded(child: _buildQrBody()),
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
          colors: [_indigoLight, _indigo],
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
                  LocaleKeys.co_sign_scan_title.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LocaleKeys.co_sign_scan_qr_subtitle.tr(),
                  style: const TextStyle(
                    color: Color(0xFFE0E7FF),
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

  Widget _buildQrBody() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: MobileScanner(
          controller: _scannerController,
          onDetect: _onQrDetect,
        ),
      ),
    );
  }
}
