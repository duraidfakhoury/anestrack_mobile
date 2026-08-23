import 'package:go_router/go_router.dart';

import '../screens/offline_cosign_status_screen.dart';

class OfflineCoSignStatusRoute {
  static const String name = '/offline-cosign-status';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const OfflineCoSignStatusScreen(),
  );
}
