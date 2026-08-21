import 'package:go_router/go_router.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';

import '../screens/supervisor_research_paper_review_screen.dart';

class SupervisorResearchPaperReviewRoute {
  static const String name = '/supervisor/acadamic/research/paper';

  static GoRoute route = GoRoute(
    path: '$name/:id',
    builder: (context, state) => SupervisorResearchPaperReviewScreen(
      paperId: state.pathParameters['id']!,
      initialPaper: state.extra as ResearchPaper?,
    ),
  );
}
