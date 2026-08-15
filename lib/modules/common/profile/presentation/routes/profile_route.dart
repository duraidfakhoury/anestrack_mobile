import 'package:go_router/go_router.dart';

import '../screens/profile_screen.dart';

class ProfileRoute {
  static const String name = '/profile';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const ProfileScreen(),
  );
}
