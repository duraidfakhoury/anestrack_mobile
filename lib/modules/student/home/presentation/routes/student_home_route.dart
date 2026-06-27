import 'package:go_router/go_router.dart';

import '../screens/student_home_screen.dart';

class StudentHomeRoute {
  static const String name = '/student-home';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const StudentHomeScreen(),
  );
}
