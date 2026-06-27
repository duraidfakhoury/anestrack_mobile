import 'package:anestrack_mobile/modules/student/education/presentation/screens/student_education_screen.dart';
import 'package:anestrack_mobile/modules/student/home/presentation/screens/student_home_screen.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/screens/student_library_screen.dart';
import 'package:anestrack_mobile/modules/student/more/presentation/screens/student_more_screen.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/screens/student_procedures_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class StudentHomeLayout extends StatefulWidget {
  const StudentHomeLayout({super.key});

  @override
  State<StudentHomeLayout> createState() => _StudentHomeLayoutState();
}

class _StudentHomeLayoutState extends State<StudentHomeLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const StudentProceduresScreen(),
    const StudentEducationScreen(),
    const StudentLibraryScreen(),
    const StudentMoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.blackAccent
            : AppColors.white,
        indicatorColor: AppColors.studentPrimary,
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14)),
        destinations: [
          NavigationDestination(
            icon: Icon(
              LucideIcons.home,
              color: _currentIndex == 0
                  ? AppColors.studentPrimary
                  : AppColors.textSecondary,
            ),
            selectedIcon: const Icon(LucideIcons.home, color: AppColors.white),
            label: "nav.home".tr(context: context),
          ),
          NavigationDestination(
            icon: Icon(
              LucideIcons.clipboardList,
              color: _currentIndex == 1
                  ? AppColors.studentPrimary
                  : AppColors.textSecondary,
            ),
            selectedIcon: const Icon(
              LucideIcons.clipboardList,
              color: AppColors.white,
            ),
            label: "nav.procedures".tr(context: context),
          ),
          NavigationDestination(
            icon: Icon(
              LucideIcons.graduationCap,
              color: _currentIndex == 2
                  ? AppColors.studentPrimary
                  : AppColors.textSecondary,
            ),
            selectedIcon: const Icon(
              LucideIcons.graduationCap,
              color: AppColors.white,
            ),
            label: "nav.education".tr(context: context),
          ),
          NavigationDestination(
            icon: Icon(
              LucideIcons.bookOpen,
              color: _currentIndex == 3
                  ? AppColors.studentPrimary
                  : AppColors.textSecondary,
            ),
            selectedIcon: const Icon(
              LucideIcons.bookOpen,
              color: AppColors.white,
            ),
            label: "nav.library".tr(context: context),
          ),
          NavigationDestination(
            icon: Icon(
              LucideIcons.moreHorizontal,
              color: _currentIndex == 4
                  ? AppColors.studentPrimary
                  : AppColors.textSecondary,
            ),
            selectedIcon: const Icon(
              LucideIcons.moreHorizontal,
              color: AppColors.white,
            ),
            label: "nav.more".tr(context: context),
          ),
        ],
      ),
    );
  }
}
