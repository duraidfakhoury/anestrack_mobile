import 'package:go_router/go_router.dart';

import '../screens/witness_procedure_screen.dart';

class WitnessProcedureRoute {
  static const String name = '/supervisor-home/witness-procedure';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const WitnessProcedureScreen(),
  );
}
