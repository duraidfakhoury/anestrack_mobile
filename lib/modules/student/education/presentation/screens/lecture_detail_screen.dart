import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lecture_detail_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/lecture_assistant_route.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/lecture_quiz_route.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/widgets/lecture_ai_summary_sheet.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/widgets/lecture_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LectureDetailScreen extends StatefulWidget {
  const LectureDetailScreen({super.key, required this.lectureId, this.initialLecture});

  final String lectureId;
  final Lecture? initialLecture;

  @override
  State<LectureDetailScreen> createState() => _LectureDetailScreenState();
}

class _LectureDetailScreenState extends State<LectureDetailScreen> {
  late final LectureDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<LectureDetailBloc>()
      ..add(FetchLectureDetailEvent(widget.lectureId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: BlocBuilder<LectureDetailBloc, BaseState<Lecture>>(
        bloc: _bloc,
        builder: (context, state) {
          final lecture = state.data ?? widget.initialLecture;
          if (lecture == null) {
            if (state.isError) {
              return SafeArea(
                child: LectureErrorView(
                  message: state.errorMessage,
                  onRetry: () => _bloc.add(
                    FetchLectureDetailEvent(widget.lectureId),
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
          return _LectureDetailBody(lecture: lecture);
        },
      ),
    );
  }
}

class _LectureDetailBody extends StatelessWidget {
  const _LectureDetailBody({required this.lecture});
  final Lecture lecture;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = lectureContentTypeVisual(lecture.contentType);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56, bottom: 24, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.studentPrimary, AppColors.studentPrimaryDark],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(LucideIcons.arrowRight, color: AppColors.white),
                    ),
                    Expanded(
                      child: Text(
                        LocaleKeys.education_lecture_detail_title.tr(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.white, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  lecture.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList.list(
            children: [
              if (lecture.description.isNotEmpty)
                Text(
                  lecture.description,
                  style: const TextStyle(fontSize: 14, color: AppColors.slate600, height: 1.6),
                ),
              if (lecture.mainGoals.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  LocaleKeys.education_main_goals_title.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 10),
                LectureMainGoalsList(goals: lecture.mainGoals),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue600,
                        foregroundColor: AppColors.white,
                      ),
                      onPressed: () => showLectureAiSummarySheet(
                        context,
                        lectureId: lecture.id,
                        lectureTitle: lecture.title,
                      ),
                      icon: const Icon(LucideIcons.fileText, size: 16),
                      label: Text(LocaleKeys.education_ai_summary.tr()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple600,
                        foregroundColor: AppColors.white,
                      ),
                      onPressed: () => context.push(
                        '${LectureAssistantRoute.name}/${lecture.id}',
                        extra: lecture,
                      ),
                      icon: const Icon(LucideIcons.sparkles, size: 16),
                      label: Text(LocaleKeys.education_ask_assistant.tr()),
                    ),
                  ),
                ],
              ),
              if (lecture.withTest) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.studentPrimary,
                      side: const BorderSide(color: AppColors.studentPrimary),
                    ),
                    onPressed: () => context.push(
                      '${LectureQuizRoute.name}/${lecture.id}',
                    ),
                    icon: const Icon(LucideIcons.clipboardCheck, size: 16),
                    label: Text(LocaleKeys.education_start_quiz.tr()),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
