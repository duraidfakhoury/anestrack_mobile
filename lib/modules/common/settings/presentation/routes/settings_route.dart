import 'package:go_router/go_router.dart';

import '../screens/settings_screen.dart';

class SettingsRoute {
  static const String name = '/settings';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const SettingsScreen(),
  );
}
