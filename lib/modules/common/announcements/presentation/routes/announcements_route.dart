import 'package:go_router/go_router.dart';

import '../screens/announcements_screen.dart';

class AnnouncementsRoute {
  static const String name = '/announcements';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const AnnouncementsScreen(),
  );
}
