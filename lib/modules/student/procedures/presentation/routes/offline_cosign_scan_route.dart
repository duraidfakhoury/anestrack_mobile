import 'package:go_router/go_router.dart';

import '../screens/offline_cosign_scan_screen.dart';

class OfflineCoSignScanRoute {
  static const String name = '/student-home/offline-cosign-scan';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const OfflineCoSignScanScreen(),
  );
}
