import 'package:go_router/go_router.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';

import '../screens/lecture_detail_screen.dart';

class LectureDetailRoute {
  static const String name = '/student-home/education/lecture';

  static GoRoute route = GoRoute(
    path: '$name/:id',
    builder: (context, state) => LectureDetailScreen(
      lectureId: state.pathParameters['id']!,
      initialLecture: state.extra as Lecture?,
    ),
  );
}
