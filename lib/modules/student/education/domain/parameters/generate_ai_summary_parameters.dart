import 'package:equatable/equatable.dart';

class GenerateAiSummaryParameters extends Equatable {
  final String lectureId;
  final bool regenerate;

  const GenerateAiSummaryParameters({
    required this.lectureId,
    this.regenerate = false,
  });

  Map<String, dynamic> toJson() => {
    'lectureId': lectureId,
    'regenerate': regenerate.toString(),
  };

  @override
  List<Object?> get props => [lectureId, regenerate];
}
