import 'package:go_router/go_router.dart';

import '../screens/student_procedures_screen.dart';
import '../screens/create_procedure_screen.dart';

class StudentProceduresRoute {
  static const String name = '/student-home/procedures';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const StudentProceduresScreen(),
    routes: [
      GoRoute(
        path: 'create',
        builder: (context, state) => const CreateProcedureScreen(),
      ),
    ],
  );
}
