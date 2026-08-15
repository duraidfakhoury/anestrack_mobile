import 'package:go_router/go_router.dart';

import '../screens/ble_debug_student_screen.dart';

class BleDebugStudentRoute {
  static const String name = '/student-home/ble-debug';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const BleDebugStudentScreen(),
  );
}
