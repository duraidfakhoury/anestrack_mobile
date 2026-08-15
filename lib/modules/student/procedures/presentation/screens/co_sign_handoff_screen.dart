import 'dart:async';

import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/co_sign_ble_bloc/co_sign_ble_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/co_sign_ble_bloc/co_sign_ble_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/co_sign_ble_bloc/co_sign_ble_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/routes/ble_debug_student_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _teal = Color(0xFF0D9488);
const _cyan = Color(0xFF0891B2);

/// Flow 1 (student side): after logging a procedure with a live co-sign
/// request, the student's phone broadcasts the procedure's co-sign code
/// over BLE (see [CoSignBleBloc]) for the supervisor's device to pick up.
/// The actual co-sign call happens on the *supervisor's* device once they
/// confirm, not here — there is no acknowledgement channel, so this screen
/// never learns definitively whether the co-sign succeeded via BLE.
///
/// If the code can't be advertised, or the window elapses (or BLE isn't
/// available at all), this screen falls back to the QR code / raw code
/// handoff shown below, which remains the ground-truth path regardless of
/// what BLE did.
class CoSignHandoffScreen extends StatefulWidget {
  final CreateProcedureResult result;

  const CoSignHandoffScreen({super.key, required this.result});

  @override
  State<CoSignHandoffScreen> createState() => _CoSignHandoffScreenState();
}

class _CoSignHandoffScreenState extends State<CoSignHandoffScreen> {
  late final CoSignBleBloc _bleBloc;
  StreamSubscription<CoSignBleState>? _bleStateSubscription;

  Timer? _timer;
  late DateTime _expiresAt;
  Duration _remaining = Duration.zero;

  String get _code => widget.result.coSignCode ?? '';

  @override
  void initState() {
    super.initState();
    _expiresAt = _resolveExpiry();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

    _bleBloc = sl<CoSignBleBloc>()
      ..add(StartCoSignBleEvent(widget.result.procedure.id, _code));
    _bleStateSubscription = _bleBloc.stream.listen((state) {
      if (state.status == CoSignBleStatus.codeSent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.co_sign_broadcasting.tr())),
        );
      }
    });
  }

  DateTime _resolveExpiry() {
    final iso = widget.result.procedure.coSignExpiresAt;
    final parsed = iso != null ? DateTime.tryParse(iso) : null;
    return parsed?.toLocal() ?? DateTime.now().add(const Duration(minutes: 10));
  }

  void _tick() {
    final left = _expiresAt.difference(DateTime.now());
    setState(() => _remaining = left.isNegative ? Duration.zero : left);
    if (left.isNegative) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bleStateSubscription?.cancel();
    _bleBloc.close();
    super.dispose();
  }

  bool get _expired => _remaining == Duration.zero;

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Format the 32-hex code into readable groups of 4.
  String get _prettyCode {
    final buf = StringBuffer();
    for (var i = 0; i < _code.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(_code[i]);
    }
    return buf.toString().toUpperCase();
  }

  void _finish() {
    context.go('/student-home/procedures');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoSignBleBloc, CoSignBleState>(
      bloc: _bleBloc,
      builder: (context, bleState) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F8FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            automaticallyImplyLeading: false,
            title: Text(
              LocaleKeys.co_sign_title.tr(),
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (kDebugMode)
                IconButton(
                  icon: const Icon(LucideIcons.bug, color: Color(0xFF9CA3AF)),
                  onPressed: () => context.push(BleDebugStudentRoute.name),
                ),
              TextButton(
                onPressed: _finish,
                child: Text(
                  LocaleKeys.co_sign_done.tr(),
                  style: const TextStyle(color: _teal),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(bleState),
                const SizedBox(height: 20),
                if (_isWaitingPhase(bleState.status))
                  _buildWaitingCard(bleState)
                else ...[
                  _buildCodeCard(),
                  const SizedBox(height: 20),
                  _buildQrCard(),
                  const SizedBox(height: 20),
                  _buildInstructions(),
                  const SizedBox(height: 20),
                  _buildFallbackNote(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isWaitingPhase(CoSignBleStatus status) => switch (status) {
    CoSignBleStatus.idle || CoSignBleStatus.advertisingCode => true,
    CoSignBleStatus.codeSent ||
    CoSignBleStatus.qrFallback ||
    CoSignBleStatus.error => false,
  };

  Widget _buildHeaderCard(CoSignBleState bleState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_teal, _cyan]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.handshake, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.co_sign_header_prompt.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.result.procedure.procedureTypeName ??
                LocaleKeys.co_sign_default_procedure.tr(),
            style: const TextStyle(color: Color(0xFFCFFAFE), fontSize: 13),
          ),
          const SizedBox(height: 10),
          _buildStatusChip(bleState.status),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CoSignBleStatus status) {
    late final IconData icon;
    late final String label;
    switch (status) {
      case CoSignBleStatus.idle:
      case CoSignBleStatus.advertisingCode:
        icon = LucideIcons.send;
        label = LocaleKeys.co_sign_broadcasting.tr();
      case CoSignBleStatus.codeSent:
      case CoSignBleStatus.qrFallback:
      case CoSignBleStatus.error:
        icon = LucideIcons.bluetoothOff;
        label = LocaleKeys.co_sign_use_qr_instead.tr();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingCard(CoSignBleState bleState) {
    final hasCountdown = bleState.status == CoSignBleStatus.advertisingCode;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAED)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          Text(
            _waitingMessage(bleState.status),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          if (hasCountdown) ...[
            const SizedBox(height: 8),
            Text(
              LocaleKeys.co_sign_time_remaining.tr(
                args: [bleState.remaining.inSeconds.toString()],
              ),
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => _bleBloc.add(UseQrFallbackEvent()),
              style: OutlinedButton.styleFrom(
                foregroundColor: _teal,
                side: const BorderSide(color: Color(0xFFCFE6E8)),
              ),
              child: Text(LocaleKeys.co_sign_use_qr_instead.tr()),
            ),
          ],
        ],
      ),
    );
  }

  String _waitingMessage(CoSignBleStatus status) => switch (status) {
    CoSignBleStatus.idle ||
    CoSignBleStatus.advertisingCode => LocaleKeys.co_sign_broadcasting.tr(),
    _ => '',
  };

  Widget _buildCodeCard() {
    final color = _expired ? const Color(0xFFC1483F) : _teal;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAED)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _expired ? LucideIcons.clockAlert : LucideIcons.clock,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                _expired
                    ? LocaleKeys.co_sign_expired.tr()
                    : LocaleKeys.co_sign_expires_in.tr(
                        args: [_formatDuration(_remaining)],
                      ),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(
            _prettyCode,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 22,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              color: _expired
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF0A5A61),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _expired
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: _code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(LocaleKeys.co_sign_code_copied.tr()),
                      ),
                    );
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: _teal,
              side: const BorderSide(color: Color(0xFFCFE6E8)),
            ),
            icon: const Icon(LucideIcons.copy, size: 16),
            label: Text(LocaleKeys.co_sign_copy_code.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAED)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            LocaleKeys.co_sign_qr_label.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5B6B73)),
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: _expired ? 0.35 : 1,
            child: QrImageView(
              data: _code,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF0A5A61),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF0A5A61),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCFE6E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Step(number: '1', text: LocaleKeys.co_sign_step1.tr()),
          _Step(number: '2', text: LocaleKeys.co_sign_step2.tr()),
          _Step(number: '3', text: LocaleKeys.co_sign_step3.tr()),
        ],
      ),
    );
  }

  Widget _buildFallbackNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF4E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3DCB5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, color: Color(0xFFD98C2B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF92400E),
                ),
                children: [
                  TextSpan(
                    text: LocaleKeys.co_sign_fallback_title.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: LocaleKeys.co_sign_fallback_body.tr()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;

  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _teal,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A2B33)),
            ),
          ),
        ],
      ),
    );
  }
}
