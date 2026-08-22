import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/evaluation_parameters.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/evaluation_action_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _Rating {
  final String value;
  final String label;
  final Color color;

  const _Rating(this.value, this.label, this.color);
}

/// Rating step shown before a supervisor co-signs or confirms a procedure
/// (`createEvaluation`). Pops `true` once the evaluation is submitted, or
/// `false`/`null` if dismissed without rating.
class EvaluationRatingSheet extends StatefulWidget {
  final String procedureId;

  const EvaluationRatingSheet({super.key, required this.procedureId});

  @override
  State<EvaluationRatingSheet> createState() => _EvaluationRatingSheetState();
}

class _EvaluationRatingSheetState extends State<EvaluationRatingSheet> {
  late final EvaluationActionBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<EvaluationActionBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  List<_Rating> get _ratings => [
    _Rating('Excellent', LocaleKeys.evaluation_excellent.tr(), const Color(0xFF2E9E6B)),
    _Rating('Good', LocaleKeys.evaluation_good.tr(), const Color(0xFF0D9488)),
    _Rating('Acceptable', LocaleKeys.evaluation_acceptable.tr(), const Color(0xFFD98C2B)),
    _Rating('Poor', LocaleKeys.evaluation_poor.tr(), const Color(0xFFC1483F)),
  ];

  void _rate(String rating) {
    _bloc.add(
      SubmitEvaluationEvent(
        EvaluationParameters(procedureId: widget.procedureId, rating: rating),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: BlocConsumer<EvaluationActionBloc, EvaluationActionState>(
          bloc: _bloc,
          listener: (context, state) {
            if (state.isSuccess) Navigator.pop(context, true);
          },
          builder: (context, state) {
            return Column(
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
                Text(
                  LocaleKeys.evaluation_title.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LocaleKeys.evaluation_subtitle.tr(),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 16),
                if (state.isError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ErrorBanner(message: state.errorMessage),
                  ),
                ..._ratings.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OutlinedButton(
                      onPressed: state.isLoading ? null : () => _rate(r.value),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: r.color,
                        side: BorderSide(color: r.color.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              r.label,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
