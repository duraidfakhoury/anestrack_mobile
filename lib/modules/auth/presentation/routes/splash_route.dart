import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';

class SplashRoute {
  static const String name = '/';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const SplashScreen(),
  );
}
