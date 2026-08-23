import 'package:anestrack_mobile/modules/auth/presentation/routes/splash_route.dart';
import 'package:anestrack_mobile/modules/student/more/presentation/routes/student_more_route.dart';
import 'package:anestrack_mobile/modules/student/presentation/routes/student_shell_route.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/routes/create_procedure_route.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/routes/co_sign_handoff_route.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/routes/ble_debug_student_route.dart';
import 'package:anestrack_mobile/modules/supervisor/home/presentation/routes/supervisor_home_route.dart';
import 'package:anestrack_mobile/modules/supervisor/presentation/routes/supervisor_shell_route.dart';
import 'package:anestrack_mobile/modules/common/profile/presentation/routes/profile_route.dart';
import 'package:anestrack_mobile/modules/common/notifications/presentation/routes/notifications_route.dart';
import 'package:anestrack_mobile/modules/common/announcements/presentation/routes/announcements_route.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/routes/co_sign_scan_route.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/routes/ble_debug_supervisor_route.dart';
import 'package:anestrack_mobile/modules/common/settings/presentation/routes/settings_route.dart';
import 'package:anestrack_mobile/modules/common/support/presentation/routes/support_route.dart';
import 'package:anestrack_mobile/modules/student/curriculum/presentation/routes/curriculum_route.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/lecture_detail_route.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/lecture_quiz_route.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/lecture_quiz_result_route.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/routes/pdf_viewer_route.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/routes/publish_research_route.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/routes/research_paper_detail_route.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/routes/create_lecture_route.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/routes/create_announcement_route.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/routes/supervisor_research_library_route.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/routes/supervisor_research_paper_review_route.dart';
import 'package:go_router/go_router.dart';

import '../../modules/auth/presentation/routes/login_route.dart';

/// The [AppRoutes] class defines a static router instance of the GoRouter class,
/// which is a routing solution commonly used in Flutter applications
/// It manages the navigation flow between different screens or pages.
/// The routes parameter specifies the available routes in the application.
/// By commenting out the class, you disable the routing functionality,
/// making it impossible to navigate between screens/pages.
///
/// define Route class
/// EX: class FeatureRoute {
///  static const String name = '/route';
///  static GoRoute route = GoRoute(
///    path: name,
///    builder: (context, state) => FeaturesScreen(),
///  );
/// }

class AppRoutes {
  static final router = GoRouter(
    initialLocation: SplashRoute.name,
    routes: [
      SplashRoute.route,
      LoginRoute.route,
      StudentMoreRoute.route,
      StudentShellRoute.route,
      SupervisorShellRoute.route,
      SupervisorHomeRoute.route,
      CreateProcedureRoute.route,
      CoSignHandoffRoute.route,
      ProfileRoute.route,
      NotificationsRoute.route,
      AnnouncementsRoute.route,
      CoSignScanRoute.route,
      BleDebugStudentRoute.route,
      BleDebugSupervisorRoute.route,
      SettingsRoute.route,
      SupportRoute.route,
      CurriculumRoute.route,
      LectureDetailRoute.route,
      LectureQuizRoute.route,
      LectureQuizResultRoute.route,
      ResearchPaperDetailRoute.route,
      PublishResearchRoute.route,
      PdfViewerRoute.route,
      CreateLectureRoute.route,
      CreateAnnouncementRoute.route,
      SupervisorResearchLibraryRoute.route,
      SupervisorResearchPaperReviewRoute.route,
    ],
  );
}
