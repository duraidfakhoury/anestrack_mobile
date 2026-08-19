import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/ai_summary_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<void> showLectureAiSummarySheet(
  BuildContext context, {
  required String lectureId,
  required String lectureTitle,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => sl<AiSummaryBloc>()
        ..add(GenerateAiSummaryEvent(lectureId: lectureId)),
      child: _AiSummarySheetContent(
        lectureId: lectureId,
        lectureTitle: lectureTitle,
      ),
    ),
  );
}

class _AiSummarySheetContent extends StatelessWidget {
  const _AiSummarySheetContent({
    required this.lectureId,
    required this.lectureTitle,
  });
  final String lectureId;
  final String lectureTitle;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(LucideIcons.fileText, color: AppColors.blue600, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      LocaleKeys.education_ai_summary_title.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                lectureTitle,
                style: const TextStyle(fontSize: 12, color: AppColors.slate500),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<AiSummaryBloc, AiSummaryState>(
                  builder: (context, state) {
                    if (state.isError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.errorMessage,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => context.read<AiSummaryBloc>().add(
                                GenerateAiSummaryEvent(lectureId: lectureId),
                              ),
                              child: Text(LocaleKeys.education_retry.tr()),
                            ),
                          ],
                        ),
                      );
                    }
                    if (!state.isSuccess || state.data == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final summary = state.data!;
                    return ListView(
                      controller: scrollController,
                      children: [
                        Text(
                          summary.summaryContent,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.slate700,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            onPressed: () => context.read<AiSummaryBloc>().add(
                              GenerateAiSummaryEvent(
                                lectureId: lectureId,
                                regenerate: true,
                              ),
                            ),
                            icon: const Icon(LucideIcons.refreshCw, size: 14),
                            label: Text(LocaleKeys.education_regenerate_summary.tr()),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
