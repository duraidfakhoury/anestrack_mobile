import 'package:go_router/go_router.dart';

import '../screens/support_screen.dart';

class SupportRoute {
  static const String name = '/support';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const SupportScreen(),
  );
}
