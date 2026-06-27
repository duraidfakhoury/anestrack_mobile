import 'package:go_router/go_router.dart';

import '../screens/supervisor_more_screen.dart';

class SupervisorMoreRoute {
  static const String name = '/supervisor-home/more';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const SupervisorMoreScreen(),
  );
}
