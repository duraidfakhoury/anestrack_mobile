import 'dart:async';

import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _teal = Color(0xFF0D9488);
const _cyan = Color(0xFF0891B2);

/// Flow 1 (student side): after logging with a live co-sign request, the phone
/// must carry the one-time [CreateProcedureResult.coSignCode] to the supervisor.
///
/// The backend accepts the code regardless of how it travels (BLE / QR / read
/// aloud). This screen surfaces the code for phone-to-phone handoff and runs the
/// 10-minute window countdown; if it lapses, the student can switch to Flow 2
/// (name a supervisor for async confirmation) without redoing any work.
class CoSignHandoffScreen extends StatefulWidget {
  final CreateProcedureResult result;

  const CoSignHandoffScreen({super.key, required this.result});

  @override
  State<CoSignHandoffScreen> createState() => _CoSignHandoffScreenState();
}

class _CoSignHandoffScreenState extends State<CoSignHandoffScreen> {
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
  }

  DateTime _resolveExpiry() {
    final iso = widget.result.procedure.coSignExpiresAt;
    final parsed = iso != null ? DateTime.tryParse(iso) : null;
    return parsed?.toLocal() ??
        DateTime.now().add(const Duration(minutes: 10));
  }

  void _tick() {
    final left = _expiresAt.difference(DateTime.now());
    setState(() => _remaining = left.isNegative ? Duration.zero : left);
    if (left.isNegative) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _expired => _remaining == Duration.zero;

  String get _formattedRemaining {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text(
          'التوقيع المباشر',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _finish,
            child: const Text('تم', style: TextStyle(color: _teal)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildCodeCard(),
            const SizedBox(height: 20),
            _buildInstructions(),
            const SizedBox(height: 20),
            _buildFallbackNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
          const Text(
            'اعرض هذا الرمز للمشرف بجانبك',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.result.procedure.procedureTypeName ?? 'إجراء طبي',
            style: const TextStyle(color: Color(0xFFCFFAFE), fontSize: 13),
          ),
        ],
      ),
    );
  }

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
                _expired ? 'انتهت المهلة' : 'ينتهي خلال $_formattedRemaining',
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
              color: _expired ? const Color(0xFF9CA3AF) : const Color(0xFF0A5A61),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _expired
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: _code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ الرمز')),
                    );
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: _teal,
              side: const BorderSide(color: Color(0xFFCFE6E8)),
            ),
            icon: const Icon(LucideIcons.copy, size: 16),
            label: const Text('نسخ الرمز'),
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
        children: const [
          _Step(number: '1', text: 'يفتح المشرف تطبيقه ويختار "توقيع بالرمز".'),
          _Step(number: '2', text: 'يُدخل هذا الرمز (أو تقرؤه له).'),
          _Step(
            number: '3',
            text: 'يرى اسمك ونوع الإجراء ثم يضغط "✓ توقيع" — يصبح موثّقاً.',
          ),
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
              text: const TextSpan(
                style: TextStyle(fontSize: 12.5, color: Color(0xFF92400E)),
                children: [
                  TextSpan(
                    text: 'إن انتهت المهلة دون توقيع، ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        'فالإجراء محفوظ بالفعل — يمكن للمشرف تأكيده لاحقاً من قائمة المهام (تأكيد غير متزامن). لن تفقد أي عمل.',
                  ),
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
            decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
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
