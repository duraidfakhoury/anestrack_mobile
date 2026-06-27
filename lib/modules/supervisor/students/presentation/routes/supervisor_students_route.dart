import 'package:go_router/go_router.dart';

import '../screens/supervisor_students_screen.dart';

class SupervisorStudentsRoute
 {
  static const String name = '/supervisor-home/students';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const SupervisorStudentsScreen(),
  );
}
