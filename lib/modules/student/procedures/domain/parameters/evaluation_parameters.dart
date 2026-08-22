import 'package:equatable/equatable.dart';

/// Parameters for `createEvaluation` (supervisor rating a procedure).
class EvaluationParameters extends Equatable {
  final String procedureId;
  final String rating; // "Excellent" | "Good" | "Acceptable" | "Poor"

  const EvaluationParameters({required this.procedureId, required this.rating});

  Map<String, dynamic> toJson() => {
    'procedureId': procedureId,
    'rating': rating,
  };

  @override
  List<Object?> get props => [procedureId, rating];
}
