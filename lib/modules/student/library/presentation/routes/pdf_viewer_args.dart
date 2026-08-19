import 'package:equatable/equatable.dart';

/// Carries the file title/URL to open via `GoRouterState.extra` — not an
/// entity, purely navigation payload.
class PdfViewerArgs extends Equatable {
  final String title;
  final String url;

  const PdfViewerArgs({required this.title, required this.url});

  @override
  List<Object?> get props => [title, url];
}
