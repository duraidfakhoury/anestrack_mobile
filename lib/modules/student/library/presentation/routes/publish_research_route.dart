import 'package:go_router/go_router.dart';

import '../screens/publish_research_screen.dart';

class PublishResearchRoute {
  static const String name = '/student-home/library/publish';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const PublishResearchScreen(),
  );
}
