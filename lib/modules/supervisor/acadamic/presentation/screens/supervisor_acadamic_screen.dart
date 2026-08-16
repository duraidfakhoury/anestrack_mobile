import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lectures_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Supervisor "Academic" tab — the educational material (lectures) available in
/// the program. Reuses the education (lectures) data layer.
class SupervisorAcadamicScreen extends StatelessWidget {
  const SupervisorAcadamicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LecturesBloc>()..add(FetchLecturesEvent()),
      child: Scaffold(
        backgroundColor: AppColors.slate50,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 56,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.supervisorPrimary, AppColors.indigo600],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الأكاديمية',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'المحاضرات والمواد التعليمية',
                    style: TextStyle(color: AppColors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<LecturesBloc, BaseState<List<Lecture>>>(
                builder: (context, state) {
                  if (state.isLoading || state.isInit) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.isError) {
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
                            Text(state.errorMessage, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<LecturesBloc>()
                                  .add(FetchLecturesEvent()),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final items = state.data ?? const [];
                  if (items.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.graduationCap,
                            size: 44,
                            color: AppColors.slate400,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'لا توجد محاضرات متاحة',
                            style: TextStyle(color: AppColors.slate500),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<LecturesBloc>().add(FetchLecturesEvent()),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _LectureTile(lecture: items[i]),
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

class _LectureTile extends StatelessWidget {
  const _LectureTile({required this.lecture});
  final Lecture lecture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.indigo200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.bookOpen,
              color: AppColors.indigo800,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lecture.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
                if (lecture.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    lecture.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (lecture.withTest)
            const Icon(
              LucideIcons.clipboardCheck,
              size: 18,
              color: AppColors.amber600,
            ),
        ],
      ),
    );
  }
}
