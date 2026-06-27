import 'package:go_router/go_router.dart';

import '../screens/supervisor_reviews_screen.dart';

class SupervisorReviewsRoute {
  static const String name = '/supervisor-home/reviews';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) => const SupervisorReviewsScreen(),
  );
}
