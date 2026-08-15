import 'package:go_router/go_router.dart';

import '../screens/notifications_screen.dart';

class NotificationsRoute {
  static const String name = '/notifications';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const NotificationsScreen(),
  );
}
