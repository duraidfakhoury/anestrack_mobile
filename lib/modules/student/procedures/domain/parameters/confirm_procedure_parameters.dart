import 'package:equatable/equatable.dart';

/// Parameters for `confirmProcedure` (supervisor, Flow 2/3).
class ConfirmProcedureParameters extends Equatable {
  final String id;
  final String decision; // "Confirm" | "Reject"
  final String? notes;

  const ConfirmProcedureParameters({
    required this.id,
    required this.decision,
    this.notes,
  });

  const ConfirmProcedureParameters.confirm(String id, {String? notes})
    : this(id: id, decision: 'Confirm', notes: notes);

  const ConfirmProcedureParameters.reject(String id, {String? notes})
    : this(id: id, decision: 'Reject', notes: notes);

  Map<String, dynamic> toJson() => {
    'id': id,
    'decision': decision,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  @override
  List<Object?> get props => [id, decision, notes];
}
