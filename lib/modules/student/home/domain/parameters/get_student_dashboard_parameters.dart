import 'package:equatable/equatable.dart';

class GetStudentDashboardParameters extends Equatable {
  /// Left null to let the backend resolve the dashboard for the currently
  /// logged-in student from the session token.
  final String? studentId;

  const GetStudentDashboardParameters({this.studentId});

  Map<String, dynamic> toJson() => {
    if (studentId != null) 'studentId': studentId,
  };

  @override
  List<Object?> get props => [studentId];
}
