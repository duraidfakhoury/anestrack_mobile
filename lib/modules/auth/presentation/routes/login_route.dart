import 'package:go_router/go_router.dart';

import '../screens/login_screen.dart';

class LoginRoute {
  static const String name = '/login';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const LoginScreen(),
  );
}
