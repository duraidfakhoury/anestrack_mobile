import 'package:equatable/equatable.dart';

/// An AI-generated summary of a [Lecture] (`AISummary` Parse class), cached per student.
class AiSummary extends Equatable {
  final String id;
  final String lectureId;
  final String summaryContent;
  final String? contentType;
  final String? createdAt;

  const AiSummary({
    required this.id,
    required this.lectureId,
    required this.summaryContent,
    this.contentType,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    lectureId,
    summaryContent,
    contentType,
    createdAt,
  ];
}
