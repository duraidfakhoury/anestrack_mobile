import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/routes/supervisor_acadamic_route.dart';
import 'package:anestrack_mobile/modules/supervisor/home/presentation/routes/supervisor_home_route.dart';
import 'package:anestrack_mobile/modules/supervisor/more/presentation/routes/Supervisor_more_route.dart';
import 'package:anestrack_mobile/modules/supervisor/presentation/layouts/supervisor_home_layout.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/routes/supervisor_reviews_route.dart';
import 'package:anestrack_mobile/modules/supervisor/students/presentation/routes/supervisor_students_route.dart';
import 'package:go_router/go_router.dart';

class SupervisorShellRoute {
  static final ShellRoute route = ShellRoute(
    builder: (context, state, child) => SupervisorHomeLayout(child: child),
    routes: [
      SupervisorHomeRoute.route,
      SupervisorAcadamicRoute.route,
      SupervisorReviewsRoute.route,
      SupervisorStudentsRoute.route,
      SupervisorMoreRoute.route,
    ],
  );
}
