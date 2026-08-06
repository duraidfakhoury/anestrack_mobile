import 'package:equatable/equatable.dart';

/// A student in a supervisor's roster, returned by the backend `listUsers`
/// cloud function (filtered to `userType: "student"`).
class Student extends Equatable {
  final String objectId;
  final String username;
  final String firstName;
  final String lastName;
  final String nationalId;
  final String mobileNumber;
  final int yearCode;
  final bool isBlocked;

  const Student({
    required this.objectId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.nationalId,
    required this.mobileNumber,
    required this.yearCode,
    required this.isBlocked,
  });

  @override
  List<Object?> get props => [
    objectId,
    username,
    firstName,
    lastName,
    nationalId,
    mobileNumber,
    yearCode,
    isBlocked,
  ];
}
