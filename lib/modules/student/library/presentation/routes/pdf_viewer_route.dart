import 'package:go_router/go_router.dart';

import '../screens/pdf_viewer_screen.dart';
import 'pdf_viewer_args.dart';

class PdfViewerRoute {
  static const String name = '/student-home/library/pdf-viewer';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) {
      final args = state.extra as PdfViewerArgs;
      return PdfViewerScreen(title: args.title, url: args.url);
    },
  );
}
