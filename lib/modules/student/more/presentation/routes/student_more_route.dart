import 'package:go_router/go_router.dart';

import '../screens/student_more_screen.dart';

class StudentMoreRoute {
  static const String name = '/student-home/more';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const StudentMoreScreen(),
  );
}
