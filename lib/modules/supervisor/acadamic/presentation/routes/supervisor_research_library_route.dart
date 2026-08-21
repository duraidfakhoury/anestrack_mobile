import 'package:go_router/go_router.dart';

import '../screens/supervisor_research_library_screen.dart';

class SupervisorResearchLibraryRoute {
  static const String name = '/supervisor/acadamic/research';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const SupervisorResearchLibraryScreen(),
  );
}
