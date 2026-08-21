import 'package:go_router/go_router.dart';

import '../screens/create_announcement_screen.dart';

class CreateAnnouncementRoute {
  static const String name = '/supervisor/acadamic/create-announcement';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const CreateAnnouncementScreen(),
  );
}
