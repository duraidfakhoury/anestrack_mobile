import 'package:equatable/equatable.dart';

/// A lecture in the education library (`Lecture` Parse class).
class Lecture extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? contentType; // Video | Document | Text
  final List<String> mainGoals;
  final bool withTest;
  final String? createdAt;
  final bool isActive;

  const Lecture({
    required this.id,
    required this.title,
    required this.description,
    this.contentType,
    this.mainGoals = const [],
    this.withTest = false,
    this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    contentType,
    mainGoals,
    withTest,
    createdAt,
    isActive,
  ];
}
