import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/relative_time.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/domain/entities/recent_activity_item.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/blocs/recent_activity_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/routes/create_announcement_route.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/routes/create_lecture_route.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/routes/supervisor_research_library_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Supervisor "Academic" tab — hub for adding lectures, reviewing student
/// research, and publishing announcements, per design-specs/supervisor-acadamic-page.png.
class SupervisorAcadamicScreen extends StatefulWidget {
  const SupervisorAcadamicScreen({super.key});

  @override
  State<SupervisorAcadamicScreen> createState() =>
      _SupervisorAcadamicScreenState();
}

class _SupervisorAcadamicScreenState extends State<SupervisorAcadamicScreen> {
  late final RecentActivityBloc _activityBloc;

  @override
  void initState() {
    super.initState();
    _activityBloc = sl<RecentActivityBloc>()..add(FetchRecentActivityEvent());
  }

  @override
  void dispose() {
    _activityBloc.close();
    super.dispose();
  }

  Future<void> _openCreateLecture() async {
    final created = await context.push<bool>(CreateLectureRoute.name);
    if (created == true) _activityBloc.add(FetchRecentActivityEvent());
  }

  Future<void> _openCreateAnnouncement() async {
    final created = await context.push<bool>(CreateAnnouncementRoute.name);
    if (created == true) _activityBloc.add(FetchRecentActivityEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  _ActionCard(
                    title: LocaleKeys.supervisor_academic_add_lecture_title.tr(),
                    subtitle:
                        LocaleKeys.supervisor_academic_add_lecture_subtitle.tr(),
                    icon: LucideIcons.upload,
                    color: AppColors.blue600,
                    onTap: _openCreateLecture,
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    title: LocaleKeys.supervisor_academic_research_library_title
                        .tr(),
                    subtitle: LocaleKeys
                        .supervisor_academic_research_library_subtitle
                        .tr(),
                    icon: LucideIcons.fileText,
                    color: AppColors.purple600,
                    onTap: () =>
                        context.push(SupervisorResearchLibraryRoute.name),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    title: LocaleKeys
                        .supervisor_academic_publish_announcement_title
                        .tr(),
                    subtitle: LocaleKeys
                        .supervisor_academic_publish_announcement_subtitle
                        .tr(),
                    icon: LucideIcons.bell,
                    color: AppColors.amber600,
                    onTap: _openCreateAnnouncement,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.supervisor_academic_recent_activity_title.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<RecentActivityBloc, RecentActivityState>(
                    bloc: _activityBloc,
                    builder: (context, state) {
                      if (state.isLoading || state.isInit) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final items = state.data ?? const [];
                      if (items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              LocaleKeys
                                  .supervisor_academic_empty_recent_activity
                                  .tr(),
                              style: const TextStyle(color: AppColors.slate400),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: items
                            .map((item) => _ActivityTile(item: item))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 56, bottom: 24, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.supervisorPrimary, AppColors.indigo600],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.supervisor_academic_header_title.tr(),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.supervisor_academic_header_subtitle.tr(),
            style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.plus, size: 18, color: AppColors.slate400),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.slate500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});
  final RecentActivityItem item;

  Color get _dotColor {
    switch (item.type) {
      case RecentActivityType.lecture:
        return AppColors.blue600;
      case RecentActivityType.research:
        return AppColors.purple600;
      case RecentActivityType.announcement:
        return AppColors.amber600;
    }
  }

  String get _label {
    switch (item.type) {
      case RecentActivityType.lecture:
        return LocaleKeys.supervisor_academic_activity_lecture_added.tr(
          args: [item.title],
        );
      case RecentActivityType.research:
        return LocaleKeys.supervisor_academic_activity_research_published.tr(
          args: [item.title],
        );
      case RecentActivityType.announcement:
        return LocaleKeys.supervisor_academic_activity_announcement_published
            .tr(args: [item.title]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.slate800,
              ),
            ),
          ),
          if (item.timestamp != null) ...[
            const SizedBox(width: 8),
            Text(
              formatRelative(item.timestamp!),
              style: const TextStyle(fontSize: 11, color: AppColors.slate400),
            ),
          ],
        ],
      ),
    );
  }
}
