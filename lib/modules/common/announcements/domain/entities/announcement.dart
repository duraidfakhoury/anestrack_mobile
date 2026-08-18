import 'package:equatable/equatable.dart';

/// An official announcement (`Announcement` Parse class).
class Announcement extends Equatable {
  final String objectId;
  final String title;
  final String content;
  final bool isImportant;
  final String? createdAt; // ISO string
  final String targetGroup; // "students", "supervisors", or "all"
  final bool isActive;
  final String className = 'Announcement';


  const Announcement({
    required this.objectId,
    required this.title,
    required this.content,
    this.isImportant = false,
    this.createdAt,
    required this.targetGroup,
    required this.isActive,
  });

  @override
  List<Object?> get props => [title, content, isImportant, createdAt, targetGroup, isActive];
}
