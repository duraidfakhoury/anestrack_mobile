import 'package:go_router/go_router.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';

import '../screens/lecture_assistant_screen.dart';

class LectureAssistantRoute {
  static const String name = '/student-home/education/lecture-assistant';

  static GoRoute route = GoRoute(
    path: '$name/:id',
    builder: (context, state) => LectureAssistantScreen(
      lectureId: state.pathParameters['id']!,
      lecture: state.extra as Lecture?,
    ),
  );
}
