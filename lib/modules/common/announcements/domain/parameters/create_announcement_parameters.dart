import 'package:equatable/equatable.dart';

/// Parameters for `createAnnouncement`.
class CreateAnnouncementParameters extends Equatable {
  final String title;
  final String content;

  /// 'all' | 'students' | 'supervisors'.
  final String targetGroup;
  final bool isImportant;

  const CreateAnnouncementParameters({
    required this.title,
    required this.content,
    required this.targetGroup,
    this.isImportant = false,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'targetGroup': targetGroup,
    'isImportant': isImportant,
  };

  @override
  List<Object?> get props => [title, content, targetGroup, isImportant];
}
