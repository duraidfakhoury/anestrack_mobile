import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lecture_assessment_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lecture_attendance_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lecture_detail_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/lecture_assistant_route.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/lecture_quiz_route.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/widgets/lecture_ai_summary_sheet.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/widgets/lecture_rating_sheet.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/widgets/lecture_widgets.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/routes/pdf_viewer_args.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/routes/pdf_viewer_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class LectureDetailScreen extends StatefulWidget {
  const LectureDetailScreen({
    super.key,
    required this.lectureId,
    this.initialLecture,
  });

  final String lectureId;
  final Lecture? initialLecture;

  @override
  State<LectureDetailScreen> createState() => _LectureDetailScreenState();
}

class _LectureDetailScreenState extends State<LectureDetailScreen> {
  late final LectureDetailBloc _detailBloc;
  late final LectureAttendanceBloc _attendanceBloc;
  late final LectureAssessmentBloc _assessmentBloc;

  @override
  void initState() {
    super.initState();
    _detailBloc = sl<LectureDetailBloc>()
      ..add(FetchLectureDetailEvent(widget.lectureId));
    // Record (or look up) attendance when the lecture opens (§8).
    _attendanceBloc = sl<LectureAttendanceBloc>()
      ..add(OpenLectureAttendanceEvent(widget.lectureId));
    // "Has a test" is decided by listLectureAssessments, not withTest (§9).
    _assessmentBloc = sl<LectureAssessmentBloc>()
      ..add(FetchAssessmentEvent(widget.lectureId));
  }

  @override
  void dispose() {
    _detailBloc.close();
    _attendanceBloc.close();
    _assessmentBloc.close();
    super.dispose();
  }

  Future<void> _onRefresh() {
    _detailBloc.add(FetchLectureDetailEvent(widget.lectureId));
    _assessmentBloc.add(FetchAssessmentEvent(widget.lectureId));
    return _detailBloc.stream.firstWhere((s) => !s.isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _detailBloc),
        BlocProvider.value(value: _attendanceBloc),
        BlocProvider.value(value: _assessmentBloc),
      ],
      child: Scaffold(
        backgroundColor: AppColors.slate50,
        body: BlocBuilder<LectureDetailBloc, BaseState<Lecture>>(
          bloc: _detailBloc,
          builder: (context, state) {
            final lecture = state.data ?? widget.initialLecture;
            if (lecture == null) {
              if (state.isError) {
                return SafeArea(
                  child: LectureErrorView(
                    message: state.errorMessage,
                    onRetry: () =>
                        _detailBloc.add(FetchLectureDetailEvent(widget.lectureId)),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }
            return _LectureDetailBody(lecture: lecture, onRefresh: _onRefresh);
          },
        ),
      ),
    );
  }
}

class _LectureDetailBody extends StatelessWidget {
  const _LectureDetailBody({required this.lecture, required this.onRefresh});
  final Lecture lecture;
  final Future<void> Function() onRefresh;

  Future<void> _openContent(BuildContext context) async {
    final url = lecture.playableUrl;
    if (url == null || url.isEmpty) return;
    // Opening the material counts as completing it (§8).
    context.read<LectureAttendanceBloc>().add(CompleteLectureAttendanceEvent());

    final isPdf = lecture.contentFile?.isPdf ?? url.toLowerCase().contains('.pdf');
    if (isPdf) {
      context.push(
        PdfViewerRoute.name,
        extra: PdfViewerArgs(title: lecture.title, url: url),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.education_cannot_open_content.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = lectureContentTypeVisual(lecture.effectiveContentType);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 56,
                bottom: 24,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.studentPrimary,
                    AppColors.studentPrimaryDark,
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          LucideIcons.arrowRight,
                          color: AppColors.white,
                        ),
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
                      const _AttendanceBadge(),
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.slate600,
                      height: 1.6,
                    ),
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
                const SizedBox(height: 20),
                _LectureContentSection(
                  lecture: lecture,
                  onOpen: () => _openContent(context),
                ),
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
                const SizedBox(height: 10),
                _QuizButton(lectureId: lecture.id),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: const BorderSide(color: AppColors.gold),
                    ),
                    onPressed: () =>
                        showLectureRatingSheet(context, lectureId: lecture.id),
                    icon: const Icon(LucideIcons.star, size: 16),
                    label: Text(LocaleKeys.education_rate_lecture.tr()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders the lecture body: inline text for a `Text` lecture, or an open/play
/// button for a `Document`/`Video` (integration §4).
class _LectureContentSection extends StatelessWidget {
  const _LectureContentSection({required this.lecture, required this.onOpen});
  final Lecture lecture;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    if (lecture.isText) {
      final body = lecture.contentText?.trim() ?? '';
      if (body.isEmpty) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
        ),
        child: SelectableText(
          body,
          style: const TextStyle(
            fontSize: 14,
            height: 1.7,
            color: AppColors.slate700,
          ),
        ),
      );
    }

    if (lecture.playableUrl == null) return const SizedBox.shrink();

    final isVideo = lecture.isVideo;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.studentPrimary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onOpen,
        icon: Icon(isVideo ? LucideIcons.play : LucideIcons.fileText, size: 18),
        label: Text(
          isVideo
              ? LocaleKeys.education_watch_video.tr()
              : LocaleKeys.education_open_document.tr(),
        ),
      ),
    );
  }
}

/// A small "attended / completed" chip driven by [LectureAttendanceBloc].
class _AttendanceBadge extends StatelessWidget {
  const _AttendanceBadge();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LectureAttendanceBloc, LectureAttendanceState>(
      builder: (context, state) {
        final attendance = state.data;
        if (attendance == null) return const SizedBox.shrink();
        final done = attendance.completed;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                done ? LucideIcons.circleCheck : LucideIcons.circleDot,
                color: AppColors.white,
                size: 14,
              ),
              const SizedBox(width: 5),
              Text(
                done
                    ? LocaleKeys.education_attendance_completed.tr()
                    : LocaleKeys.education_attendance_recorded.tr(),
                style: const TextStyle(color: AppColors.white, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shows the quiz button only when `listLectureAssessments` confirms a test
/// exists (integration §9) — not the unreliable `withTest` flag.
class _QuizButton extends StatelessWidget {
  const _QuizButton({required this.lectureId});
  final String lectureId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LectureAssessmentBloc, LectureAssessmentState>(
      builder: (context, state) {
        if (!state.isSuccess || state.data == null) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.studentPrimary,
              side: const BorderSide(color: AppColors.studentPrimary),
            ),
            onPressed: () =>
                context.push('${LectureQuizRoute.name}/$lectureId'),
            icon: const Icon(LucideIcons.clipboardCheck, size: 16),
            label: Text(LocaleKeys.education_start_quiz.tr()),
          ),
        );
      },
    );
  }
}
