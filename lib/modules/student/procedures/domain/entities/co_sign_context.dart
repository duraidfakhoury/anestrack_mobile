import 'package:equatable/equatable.dart';

/// The non-PII preview a supervisor sees after receiving a co-sign code, before
/// they tap ✓ Co-sign. Returned by `getCoSignContext`. Never contains the
/// patient name — only who the student is and what they logged.
class CoSignContext extends Equatable {
  final String? procedureId;
  final String? studentName;
  final String? procedureType;
  final String? expiresAt; // ISO-8601

  const CoSignContext({
    this.procedureId,
    this.studentName,
    this.procedureType,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [procedureId, studentName, procedureType, expiresAt];
}
