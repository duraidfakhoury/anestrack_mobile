import 'package:go_router/go_router.dart';

import '../screens/create_lecture_screen.dart';

class CreateLectureRoute {
  static const String name = '/supervisor/acadamic/create-lecture';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const CreateLectureScreen(),
  );
}
