import 'package:equatable/equatable.dart';

/// Parameters for `createLecture`.
class CreateLectureParameters extends Equatable {
  final String title;
  final String description;

  /// 'Video' | 'Document' | 'Link'.
  final String contentType;

  /// A plain URL (Video/Link) or a base64 data URI (Document).
  final String contentUrl;

  const CreateLectureParameters({
    required this.title,
    required this.description,
    required this.contentType,
    required this.contentUrl,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'contentType': contentType,
    'contentUrl': contentUrl,
  };

  @override
  List<Object?> get props => [title, description, contentType, contentUrl];
}
