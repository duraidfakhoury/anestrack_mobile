import 'package:go_router/go_router.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';

import '../screens/research_paper_detail_screen.dart';

class ResearchPaperDetailRoute {
  static const String name = '/student-home/library/paper';

  static GoRoute route = GoRoute(
    path: '$name/:id',
    builder: (context, state) => ResearchPaperDetailScreen(
      paperId: state.pathParameters['id']!,
      initialPaper: state.extra as ResearchPaper?,
    ),
  );
}
