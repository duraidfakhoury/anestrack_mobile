import 'package:equatable/equatable.dart';

/// Parameters for `createLectureEvaluation` (integration §12).
///
/// The server does no range check on [rating], so the app owns the scale —
/// clamp to 1–5 before sending.
class CreateLectureEvaluationParameters extends Equatable {
  final String lectureId;
  final int rating;
  final String? feedback;

  const CreateLectureEvaluationParameters({
    required this.lectureId,
    required this.rating,
    this.feedback,
  });

  Map<String, dynamic> toJson() => {
    'lectureId': lectureId,
    'rating': rating.clamp(1, 5),
    if (feedback != null && feedback!.trim().isNotEmpty)
      'feedback': feedback!.trim(),
  };

  @override
  List<Object?> get props => [lectureId, rating, feedback];
}
