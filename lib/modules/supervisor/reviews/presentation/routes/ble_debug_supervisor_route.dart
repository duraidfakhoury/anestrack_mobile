import 'package:go_router/go_router.dart';

import '../screens/ble_debug_supervisor_screen.dart';

class BleDebugSupervisorRoute {
  static const String name = '/supervisor-home/ble-debug';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const BleDebugSupervisorScreen(),
  );
}
