import 'package:equatable/equatable.dart';

/// An upload attached to `createLecture`. Exactly one of the three accepted
/// shapes (integration §7):
/// - inline base64: `{base64, name}`
/// - two-step `/files` result: `{name, url}`
/// - reuse a stored file: `{id}`
class LectureUploadFile extends Equatable {
  /// Raw base64 (no data-URI prefix) with its [name].
  final String? base64;

  /// Uploaded file URL from the two-step `/files` endpoint.
  final String? url;

  /// Human filename — Arabic is fine, the backend percent-encodes it.
  final String? name;

  /// `objectId` of an already-stored File to reuse.
  final String? id;

  /// Optional byte size, sent alongside a `{name, url}` upload.
  final int? size;

  const LectureUploadFile.base64({required this.base64, required this.name})
    : url = null,
      id = null,
      size = null;

  const LectureUploadFile.uploaded({
    required this.name,
    required this.url,
    this.size,
  }) : base64 = null,
       id = null;

  const LectureUploadFile.reuse(this.id)
    : base64 = null,
      url = null,
      name = null,
      size = null;

  Map<String, dynamic> toJson() {
    if (id != null) return {'id': id};
    if (url != null) {
      return {'name': name, 'url': url, if (size != null) 'size': size};
    }
    return {'base64': base64, 'name': name};
  }

  @override
  List<Object?> get props => [base64, url, name, id, size];
}

/// Parameters for `createLecture` (integration §6).
class CreateLectureParameters extends Equatable {
  final String title;

  /// 'Video' | 'Document' | 'Text' (case-sensitive).
  final String contentType;

  final String? description;

  /// The lecture body — required for a `Text` lecture.
  final String? contentText;

  /// External link — a `Video`/`Document` lecture needs either this or [file].
  final String? contentUrl;

  final LectureUploadFile? file;
  final List<String> mainGoals;
  final bool withTest;

  const CreateLectureParameters({
    required this.title,
    required this.contentType,
    this.description,
    this.contentText,
    this.contentUrl,
    this.file,
    this.mainGoals = const [],
    this.withTest = false,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'contentType': contentType,
    if (description != null && description!.trim().isNotEmpty)
      'description': description!.trim(),
    if (contentText != null && contentText!.trim().isNotEmpty)
      'contentText': contentText!.trim(),
    if (contentUrl != null && contentUrl!.trim().isNotEmpty)
      'contentUrl': contentUrl!.trim(),
    if (file != null) 'file': file!.toJson(),
    if (mainGoals.isNotEmpty) 'mainGoals': mainGoals,
    'withTest': withTest,
  };

  @override
  List<Object?> get props => [
    title,
    contentType,
    description,
    contentText,
    contentUrl,
    file,
    mainGoals,
    withTest,
  ];
}
