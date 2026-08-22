import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lecture_evaluation_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Prompts the student to rate a lecture 1–5 stars with optional feedback,
/// posting `createLectureEvaluation` (integration §12).
Future<void> showLectureRatingSheet(
  BuildContext context, {
  required String lectureId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => sl<LectureEvaluationBloc>(),
      child: _LectureRatingSheet(lectureId: lectureId),
    ),
  );
}

class _LectureRatingSheet extends StatefulWidget {
  const _LectureRatingSheet({required this.lectureId});
  final String lectureId;

  @override
  State<_LectureRatingSheet> createState() => _LectureRatingSheetState();
}

class _LectureRatingSheetState extends State<_LectureRatingSheet> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: BlocConsumer<LectureEvaluationBloc, LectureEvaluationState>(
        listener: (context, state) {
          if (state.isSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocaleKeys.education_rating_thanks.tr()),
                backgroundColor: AppColors.studentPrimary,
              ),
            );
          } else if (state.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.red600,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.education_rate_lecture_title.tr(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return IconButton(
                    onPressed: () => setState(() => _rating = i + 1),
                    icon: Icon(
                      LucideIcons.star,
                      color: filled ? AppColors.gold : AppColors.slate400,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: LocaleKeys.education_rating_feedback_hint.tr(),
                  hintStyle: const TextStyle(
                    color: AppColors.slate400,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.studentPrimary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _rating == 0 || state.isLoading
                      ? null
                      : () => context.read<LectureEvaluationBloc>().add(
                          SubmitLectureRatingEvent(
                            lectureId: widget.lectureId,
                            rating: _rating,
                            feedback: _feedbackController.text,
                          ),
                        ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(LocaleKeys.education_submit_rating.tr()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
