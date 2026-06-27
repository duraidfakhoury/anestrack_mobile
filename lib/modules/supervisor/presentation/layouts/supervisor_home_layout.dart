import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/routes/supervisor_acadamic_route.dart';
import 'package:anestrack_mobile/modules/supervisor/home/presentation/routes/supervisor_home_route.dart';
import 'package:anestrack_mobile/modules/supervisor/more/presentation/routes/supervisor_more_route.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/routes/supervisor_reviews_route.dart';
import 'package:anestrack_mobile/modules/supervisor/students/presentation/routes/supervisor_students_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class SupervisorHomeLayout extends StatelessWidget {
  const SupervisorHomeLayout({super.key, required this.child});

  final Widget child;
  static const Color _activeColor = AppColors.supervisorPrimary;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _currentIndexFor(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          context.go(_navItems[index].path);
        },
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.blackAccent
            : AppColors.white,
        indicatorColor: _activeColor,
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14)),
        destinations: _navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(
                  item.icon,
                  color: currentIndex == item.index
                      ? _activeColor
                      : AppColors.textSecondary,
                ),
                selectedIcon: Icon(item.icon, color: AppColors.white),
                label: item.labelKey.tr(context: context),
              ),
            )
            .toList(),
      ),
    );
  }

  int _currentIndexFor(String path) {
    final match = _navItems.firstWhere(
      (item) => item.matchSubRoutes
          ? path.startsWith(item.path)
          : path == item.path,
      orElse: () => _navItems.first,
    );
    return match.index;
  }
}

class _SupervisorNavItem {
  const _SupervisorNavItem({
    required this.index,
    required this.path,
    required this.labelKey,
    required this.icon,
    this.matchSubRoutes = true,
  });

  final int index;
  final String path;
  final String labelKey;
  final IconData icon;
  final bool matchSubRoutes;
}

const List<_SupervisorNavItem> _navItems = [
  _SupervisorNavItem(
    index: 0,
    path: SupervisorHomeRoute.name,
    labelKey: 'nav.home',
    icon: LucideIcons.home,
    matchSubRoutes: false,
  ),
  _SupervisorNavItem(
    index: 1,
    path: SupervisorReviewsRoute.name,
    labelKey: 'nav.review',
    icon: LucideIcons.clipboardCheck,
  ),
  _SupervisorNavItem(
    index: 2,
    path: SupervisorStudentsRoute.name,
    labelKey: 'nav.students',
    icon: LucideIcons.users,
  ),
  _SupervisorNavItem(
    index: 3,
    path: SupervisorAcadamicRoute.name,
    labelKey: 'nav.academic',
    icon: LucideIcons.bookOpen,
  ),
  _SupervisorNavItem(
    index: 4,
    path: SupervisorMoreRoute.name,
    labelKey: 'nav.more',
    icon: LucideIcons.moreHorizontal,
  ),
];
