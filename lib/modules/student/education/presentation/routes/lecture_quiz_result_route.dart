import 'package:go_router/go_router.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/quiz_result_args.dart';

import '../screens/lecture_quiz_result_screen.dart';

class LectureQuizResultRoute {
  static const String name = '/student-home/education/lecture-quiz-result';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => LectureQuizResultScreen(
      args: state.extra as QuizResultArgs?,
    ),
  );
}
