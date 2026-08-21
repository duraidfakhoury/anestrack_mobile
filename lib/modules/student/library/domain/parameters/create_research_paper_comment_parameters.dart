import 'package:equatable/equatable.dart';

/// Parameters for `createResearchPaperComment`.
class CreateResearchPaperCommentParameters extends Equatable {
  final String paperId;
  final String content;

  const CreateResearchPaperCommentParameters({
    required this.paperId,
    required this.content,
  });

  Map<String, dynamic> toJson() => {'paperId': paperId, 'content': content};

  @override
  List<Object?> get props => [paperId, content];
}
