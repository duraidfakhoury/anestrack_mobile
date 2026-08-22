import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_file.dart';

/// A lecture in the education library (`Lecture` Parse class).
class Lecture extends Equatable {
  final String id;
  final String title;
  final String description;

  /// `Video` | `Document` | `Text` (case-sensitive). May be null on older
  /// lectures — treat a missing value as `Document` (integration §4).
  final String? contentType;

  /// The full lecture body — the thing a `Text` lecture *is*.
  final String? contentText;

  /// External link — a YouTube/streaming URL, or a hosted PDF.
  final String? contentUrl;

  /// A file uploaded to the backend, expanded server-side.
  final LectureFile? contentFile;

  final List<String> mainGoals;

  /// Hint that an assessment exists. Not authoritative — confirm with
  /// `listLectureAssessments` before showing the quiz button (integration §9).
  final bool withTest;

  /// Shallow assessment pointer id, when present.
  final String? assessmentId;

  final String? createdAt;
  final bool isActive;

  const Lecture({
    required this.id,
    required this.title,
    required this.description,
    this.contentType,
    this.contentText,
    this.contentUrl,
    this.contentFile,
    this.mainGoals = const [],
    this.withTest = false,
    this.assessmentId,
    this.createdAt,
    this.isActive = true,
  });

  /// Effective content type, defaulting a missing/blank value to `Document`
  /// per the integration guide's back-compat rule.
  String get effectiveContentType {
    final t = contentType?.trim();
    if (t == null || t.isEmpty) return 'Document';
    return t;
  }

  bool get isText => effectiveContentType == 'Text';
  bool get isVideo => effectiveContentType == 'Video';
  bool get isDocument => effectiveContentType == 'Document';

  /// The URL to open for a `Document`/`Video` lecture: the uploaded file
  /// first, then the external URL (integration §4 rendering rule).
  String? get playableUrl => contentFile?.url ?? contentUrl;

  /// Whether this lecture has renderable content of any kind.
  bool get hasContent =>
      (isText && (contentText?.trim().isNotEmpty ?? false)) ||
      (playableUrl?.isNotEmpty ?? false);

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    contentType,
    contentText,
    contentUrl,
    contentFile,
    mainGoals,
    withTest,
    assessmentId,
    createdAt,
    isActive,
  ];
}
