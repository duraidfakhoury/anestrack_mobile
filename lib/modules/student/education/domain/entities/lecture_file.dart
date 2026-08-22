import 'package:equatable/equatable.dart';

/// A file attached to a [Lecture] (`contentFile` on the `Lecture` Parse class).
///
/// The backend expands this server-side; the readable URL lives at
/// [url] (already absolute, needs no headers). See integration §4.
class LectureFile extends Equatable {
  /// The `File` object id — reusable as `{"id": ...}` when publishing.
  final String id;

  /// Absolute, header-less URL to the stored file.
  final String? url;

  /// File extension picked by the backend: `pdf`, `mp4`, ... Used to choose
  /// the viewer.
  final String? type;

  /// Size in bytes, for a "large download" warning on mobile data.
  final int? fileSize;

  /// Percent-encoded storage name. Never shown to the user — decode only if
  /// needed for a "save as" filename.
  final String? name;

  const LectureFile({
    required this.id,
    this.url,
    this.type,
    this.fileSize,
    this.name,
  });

  bool get isPdf => (type ?? '').toLowerCase() == 'pdf' ||
      (url ?? '').toLowerCase().contains('.pdf');

  @override
  List<Object?> get props => [id, url, type, fileSize, name];
}
