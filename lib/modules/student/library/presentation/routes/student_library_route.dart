import 'package:go_router/go_router.dart';

import '../screens/student_library_screen.dart';

class StudentLibraryRoute {
  static const String name = '/student-home/library';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const StudentLibraryScreen(),
  );
}
