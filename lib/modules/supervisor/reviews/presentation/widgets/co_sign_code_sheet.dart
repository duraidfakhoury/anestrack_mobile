import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/co_sign_context.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/co_sign_parameters.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/co_sign_action_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/co_sign_context_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _indigo = Color(0xFF4338CA);

/// Supervisor co-sign-by-code flow. The student's phone shows a one-time code
/// (BLE/QR/read aloud); the supervisor enters it here. We preview the non-PII
/// context (`getCoSignContext`), then co-sign (`coSignProcedure`). Possessing
/// the code proves proximity, so this yields the top **Verified** tier.
class CoSignCodeSheet extends StatefulWidget {
  const CoSignCodeSheet({super.key});

  @override
  State<CoSignCodeSheet> createState() => _CoSignCodeSheetState();
}

class _CoSignCodeSheetState extends State<CoSignCodeSheet> {
  final TextEditingController _codeController = TextEditingController();
  late final CoSignContextBloc _contextBloc;
  late final CoSignActionBloc _actionBloc;

  @override
  void initState() {
    super.initState();
    _contextBloc = sl<CoSignContextBloc>();
    _actionBloc = sl<CoSignActionBloc>();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _contextBloc.close();
    _actionBloc.close();
    super.dispose();
  }

  String get _normalizedCode =>
      _codeController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase();

  void _preview() {
    FocusScope.of(context).unfocus();
    if (_normalizedCode.isEmpty) return;
    _contextBloc.add(FetchCoSignContextEvent(_normalizedCode));
  }

  void _coSign() {
    _actionBloc.add(
      SubmitCoSignEvent(
        CoSignParameters(
          coSignCode: _normalizedCode,
          proximity: const {'method': 'MANUAL'},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: BlocListener<CoSignActionBloc, CoSignActionState>(
          bloc: _actionBloc,
          listener: (context, state) {
            if (state.isSuccess && state.data != null) {
              Navigator.pop(context, true);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EAED),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'توقيع بالرمز',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'أدخل الرمز الظاهر على هاتف الطالب',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F ]')),
                ],
                decoration: InputDecoration(
                  hintText: 'xxxx xxxx xxxx ...',
                  filled: true,
                  fillColor: const Color(0xFFF5F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(LucideIcons.clipboardPaste, size: 20),
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) {
                        _codeController.text = data!.text!.trim();
                      }
                    },
                  ),
                ),
                onSubmitted: (_) => _preview(),
              ),
              const SizedBox(height: 16),
              BlocBuilder<CoSignContextBloc, CoSignContextState>(
                bloc: _contextBloc,
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state.isError) {
                    return _ErrorBanner(message: state.errorMessage);
                  }
                  if (state.isSuccess && state.data != null) {
                    return _ContextPreview(context: state.data!);
                  }
                  return _buildPreviewButton();
                },
              ),
              BlocBuilder<CoSignContextBloc, CoSignContextState>(
                bloc: _contextBloc,
                builder: (context, ctxState) {
                  if (!(ctxState.isSuccess && ctxState.data != null)) {
                    return const SizedBox.shrink();
                  }
                  return BlocBuilder<CoSignActionBloc, CoSignActionState>(
                    bloc: _actionBloc,
                    builder: (context, actState) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (actState.isError)
                              _ErrorBanner(message: actState.errorMessage),
                            ElevatedButton.icon(
                              onPressed: actState.isLoading ? null : _coSign,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E9E6B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: actState.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Icon(LucideIcons.check, size: 18),
                              label: const Text(
                                '✓ توقيع الإجراء',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewButton() {
    return ElevatedButton(
      onPressed: _preview,
      style: ElevatedButton.styleFrom(
        backgroundColor: _indigo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'معاينة',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}

class _ContextPreview extends StatelessWidget {
  final CoSignContext context;

  const _ContextPreview({required this.context});

  @override
  Widget build(BuildContext c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCFE6E8)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF0D9488),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.user, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.studentName ?? 'طالب',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0A5A61),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.procedureType ?? 'إجراء طبي',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF5B6B73)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBECEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF2CFCC)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.circleAlert, color: Color(0xFFC1483F), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFFC1483F)),
            ),
          ),
        ],
      ),
    );
  }
}
