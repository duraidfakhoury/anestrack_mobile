import 'package:go_router/go_router.dart';

import '../screens/create_procedure_screen.dart';

class CreateProcedureRoute {
  static const String name = '/student-home/create';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const CreateProcedureScreen(),
  );
}
