import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lectures_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StudentEducationScreen extends StatelessWidget {
  const StudentEducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LecturesBloc>()..add(FetchLecturesEvent()),
      child: Scaffold(
        backgroundColor: AppColors.slate50,
        body: Column(
          children: [
            _Header(title: 'nav.education'.tr(context: context)),
            Expanded(
              child: BlocBuilder<LecturesBloc, BaseState<List<Lecture>>>(
                builder: (context, state) {
                  if (state.isLoading || state.isInit) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.isError) {
                    return _ErrorView(
                      message: state.errorMessage,
                      onRetry: () =>
                          context.read<LecturesBloc>().add(FetchLecturesEvent()),
                    );
                  }
                  final items = state.data ?? const [];
                  if (items.isEmpty) {
                    return const _EmptyView(
                      icon: LucideIcons.graduationCap,
                      message: 'لا توجد محاضرات متاحة',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<LecturesBloc>().add(FetchLecturesEvent()),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _LectureCard(lecture: items[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 56, bottom: 20, left: 20, right: 20),
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
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'المحاضرات والمواد التعليمية',
            style: TextStyle(color: AppColors.studentPrimaryLight, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LectureCard extends StatelessWidget {
  const _LectureCard({required this.lecture});
  final Lecture lecture;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _visualFor(lecture.contentType);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lecture.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
              ),
              if (lecture.withTest)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.amber200),
                  ),
                  child: const Text(
                    'اختبار',
                    style: TextStyle(
                      color: AppColors.amber700,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (lecture.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              lecture.description,
              style: const TextStyle(fontSize: 12, color: AppColors.slate600),
            ),
          ],
          if (lecture.mainGoals.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...lecture.mainGoals.map(
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
            ),
          ],
        ],
      ),
    );
  }

  (IconData, Color) _visualFor(String? contentType) {
    switch (contentType) {
      case 'Video':
        return (LucideIcons.play, AppColors.red600);
      case 'Document':
        return (LucideIcons.fileText, AppColors.blue600);
      case 'Text':
        return (LucideIcons.bookOpen, AppColors.studentPrimary);
      default:
        return (LucideIcons.graduationCap, AppColors.studentPrimary);
    }
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.icon, required this.message});
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
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
            const Icon(LucideIcons.circleAlert, size: 44, color: AppColors.red600),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
