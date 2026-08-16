import 'package:go_router/go_router.dart';

import '../screens/curriculum_screen.dart';

class CurriculumRoute {
  static const String name = '/curriculum';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const CurriculumScreen(),
  );
}
