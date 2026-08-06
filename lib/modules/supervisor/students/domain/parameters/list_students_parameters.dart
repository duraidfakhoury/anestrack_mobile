import 'package:equatable/equatable.dart';

/// Parameters for the supervisor `listStudents` query. All optional.
/// `userType` is intentionally not exposed here — the data source always
/// fixes it to `"student"`.
class ListStudentsParameters extends Equatable {
  final String? yearCode;
  final int? limit;
  final int? skip;

  const ListStudentsParameters({this.yearCode, this.limit, this.skip});

  Map<String, dynamic> toJson() => {
    if (yearCode != null) 'yearCode': yearCode,
    if (limit != null) 'limit': limit,
    if (skip != null) 'skip': skip,
  };

  @override
  List<Object?> get props => [yearCode, limit, skip];
}
