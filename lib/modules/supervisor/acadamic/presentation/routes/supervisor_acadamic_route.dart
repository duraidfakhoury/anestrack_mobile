import 'package:go_router/go_router.dart';

import '../screens/supervisor_acadamic_screen.dart';

class SupervisorAcadamicRoute {
  static const String name = '/supervisor/acadamic';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const SupervisorAcadamicScreen(),
  );
}
