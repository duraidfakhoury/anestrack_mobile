import 'package:go_router/go_router.dart';

import '../screens/student_education_screen.dart';

class StudentEducationRoute {
  static const String name = '/student-home/education';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const StudentEducationScreen(),
  );
}
