import 'package:anestrack_mobile/modules/student/education/presentation/routes/student_education_route.dart';
import 'package:anestrack_mobile/modules/student/home/presentation/routes/student_home_route.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/routes/student_library_route.dart';
import 'package:anestrack_mobile/modules/student/more/presentation/routes/student_more_route.dart';
import 'package:anestrack_mobile/modules/student/presentation/layouts/student_home_layout.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/routes/student_procedures_route.dart';
import 'package:go_router/go_router.dart';

class StudentShellRoute {
  static final ShellRoute route = ShellRoute(
    builder: (context, state, child) => StudentHomeLayout(),
    routes: [
      StudentHomeRoute.route,
      StudentProceduresRoute.route,
      StudentEducationRoute.route,
      StudentLibraryRoute.route,
      StudentMoreRoute.route,
    ],
  );
}
