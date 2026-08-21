import 'package:equatable/equatable.dart';

/// A note/comment left on a research paper (`ResearchPaperComment` Parse class).
class ResearchPaperComment extends Equatable {
  final String id;
  final String content;
  final String authorName;
  final String? authorUserType;
  final String? createdAt;

  const ResearchPaperComment({
    required this.id,
    required this.content,
    required this.authorName,
    this.authorUserType,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    authorName,
    authorUserType,
    createdAt,
  ];
}
