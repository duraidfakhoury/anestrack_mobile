import 'package:equatable/equatable.dart';

/// A research paper in the library (`ResearchPaper` Parse class).
class ResearchPaper extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> authors;
  final String? fileUrl;
  final String? publishedAt;
  final String? studentName;

  const ResearchPaper({
    required this.id,
    required this.title,
    required this.description,
    this.authors = const [],
    this.fileUrl,
    this.publishedAt,
    this.studentName,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    authors,
    fileUrl,
    publishedAt,
    studentName,
  ];
}
