import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_question.dart';

/// A comprehension quiz (`LectureAssessment` Parse class) tied to a [Lecture].
class LectureAssessment extends Equatable {
  final String id;
  final String lectureId;
  final String title;
  final List<AssessmentQuestion> questions;
  final double totalMarks;

  const LectureAssessment({
    required this.id,
    required this.lectureId,
    required this.title,
    required this.questions,
    this.totalMarks = 0,
  });

  @override
  List<Object?> get props => [id, lectureId, title, questions, totalMarks];
}
