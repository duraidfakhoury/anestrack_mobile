import 'package:go_router/go_router.dart';

import '../screens/lecture_quiz_screen.dart';

class LectureQuizRoute {
  static const String name = '/student-home/education/lecture-quiz';

  static GoRoute route = GoRoute(
    path: '$name/:id',
    builder: (context, state) => LectureQuizScreen(
      lectureId: state.pathParameters['id']!,
    ),
  );
}
