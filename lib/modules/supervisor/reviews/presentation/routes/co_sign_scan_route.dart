import 'package:go_router/go_router.dart';

import '../screens/co_sign_scan_screen.dart';

class CoSignScanRoute {
  static const String name = '/supervisor-home/co-sign-scan';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const CoSignScanScreen(),
  );
}
