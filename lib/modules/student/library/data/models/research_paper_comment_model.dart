import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper_comment.dart';

/// Parses the `ResearchPaperComment` object returned by
/// `listResearchPaperComments` / `createResearchPaperComment`. Field names
/// are confirmed against a live response:
/// ```json
/// {
///   "paper": { ... },
///   "author": { "FirstName": "...", "LastName": "...", "username": "...", "userType": "..." },
///   "content": "...",
///   "createdAt": "2026-08-21T18:11:47.916Z",
///   "objectId": "hjsg3V2JnV"
/// }
/// ```
/// Note: `author` is the raw Parse `_User` object and may carry sensitive
/// fields (sessionToken, national ID, etc.) — only display-safe fields are
/// read here, and the raw map must never be logged.
class ResearchPaperCommentModel extends ResearchPaperComment {
  const ResearchPaperCommentModel({
    required super.id,
    required super.content,
    required super.authorName,
    super.authorUserType,
    super.createdAt,
  });

  factory ResearchPaperCommentModel.fromJson(Map<String, dynamic> json) {
    final author = (json['author'] as Map?)?.cast<String, dynamic>() ?? const {};
    final firstName =
        author['FirstName'] as String? ?? author['firstName'] as String? ?? '';
    final lastName =
        author['LastName'] as String? ?? author['lastName'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();
    final username = author['username'] as String? ?? '';

    return ResearchPaperCommentModel(
      id: json['objectId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorName: fullName.isNotEmpty ? fullName : username,
      authorUserType: author['userType'] as String?,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static String? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map && value['iso'] != null) return value['iso'] as String;
    return null;
  }
}
