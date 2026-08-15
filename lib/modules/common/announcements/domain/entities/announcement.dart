import 'package:equatable/equatable.dart';

/// An official announcement (`Announcement` Parse class).
class Announcement extends Equatable {
  final String id;
  final String title;
  final String content;
  final bool isImportant;
  final String? createdAt; // ISO string

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.isImportant = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, content, isImportant, createdAt];
}
