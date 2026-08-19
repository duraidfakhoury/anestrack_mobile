import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Icon + accent color for a lecture's `contentType` (Video | Document | Link).
(IconData, Color) lectureContentTypeVisual(String? contentType) {
  switch (contentType) {
    case 'Video':
      return (LucideIcons.play, AppColors.red600);
    case 'Document':
      return (LucideIcons.fileText, AppColors.blue600);
    case 'Link':
      return (LucideIcons.link, AppColors.studentPrimary);
    default:
      return (LucideIcons.graduationCap, AppColors.studentPrimary);
  }
}

String lectureContentTypeLabel(String? contentType) {
  switch (contentType) {
    case 'Video':
      return LocaleKeys.education_filter_video.tr();
    case 'Document':
      return LocaleKeys.education_filter_document.tr();
    case 'Link':
      return LocaleKeys.education_filter_link.tr();
    default:
      return '';
  }
}

class LectureMainGoalsList extends StatelessWidget {
  const LectureMainGoalsList({super.key, required this.goals});
  final List<String> goals;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: goals
          .map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.check,
                    size: 14,
                    color: AppColors.studentPrimary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      goal,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.slate600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class LectureEmptyView extends StatelessWidget {
  const LectureEmptyView({super.key, required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: AppColors.slate400),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.slate500)),
        ],
      ),
    );
  }
}

class LectureErrorView extends StatelessWidget {
  const LectureErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.circleAlert,
              size: 44,
              color: AppColors.red600,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(LocaleKeys.education_retry.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
