import 'package:equatable/equatable.dart';

class ListProceduresParameters extends Equatable {
  final String? status;
  final String? studentId;
  final int? limit;
  final int? skip;

  const ListProceduresParameters({
    this.status,
    this.studentId,
    this.limit,
    this.skip,
  });

  Map<String, dynamic> toJson() => {
    if (status != null) 'status': status,
    if (studentId != null) 'studentId': studentId,
    if (limit != null) 'limit': limit,
    if (skip != null) 'skip': skip,
  };

  @override
  List<Object?> get props => [status, studentId, limit, skip];
}
