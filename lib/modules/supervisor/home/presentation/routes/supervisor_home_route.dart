import 'package:go_router/go_router.dart';

import '../screens/supervisor_home_screen.dart';

class SupervisorHomeRoute {
  static const String name = '/supervisor-home';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const SupervisorHomeScreen(),
  );
}
