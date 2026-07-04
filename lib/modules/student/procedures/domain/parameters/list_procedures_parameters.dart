import 'package:equatable/equatable.dart';

/// Parameters for `listProcedures`. All optional. In addition to status, the
/// backend supports reliability-review filters (assuranceLevel, anomaly flag,
/// worstFirst ordering).
class ListProceduresParameters extends Equatable {
  final String? status; // Pending, Approved, Rejected
  final String? studentId;
  final String? assuranceLevel; // Verified, Attested, Flagged
  final String? flag; // e.g. BULK_ENTRY, BACKDATED
  final bool? worstFirst;
  final int? limit;
  final int? skip;

  const ListProceduresParameters({
    this.status,
    this.studentId,
    this.assuranceLevel,
    this.flag,
    this.worstFirst,
    this.limit,
    this.skip,
  });

  Map<String, dynamic> toJson() => {
    if (status != null) 'status': status,
    if (studentId != null) 'studentId': studentId,
    if (assuranceLevel != null) 'assuranceLevel': assuranceLevel,
    if (flag != null) 'flag': flag,
    if (worstFirst != null) 'worstFirst': worstFirst,
    if (limit != null) 'limit': limit,
    if (skip != null) 'skip': skip,
  };

  @override
  List<Object?> get props => [
    status,
    studentId,
    assuranceLevel,
    flag,
    worstFirst,
    limit,
    skip,
  ];
}
