import 'package:equatable/equatable.dart';

/// The currently authenticated user, returned by the backend `getCurrentUser`
/// cloud function (a flat, already-mapped object — NOT Parse-serialized).
class CurrentUser extends Equatable {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String nationalId;
  final String mobileNumber;
  final String userType;
  final int? yearCode;
  final String? employeeId;
  final String? employeePosition;
  final String? employeeEmail;
  final String? alias;
  final String? professionalTitle;
  final bool isSuperAdmin;
  final bool isBlocked;

  const CurrentUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.nationalId,
    required this.mobileNumber,
    required this.userType,
    this.yearCode,
    this.employeeId,
    this.employeePosition,
    this.employeeEmail,
    this.alias,
    this.professionalTitle,
    this.isSuperAdmin = false,
    this.isBlocked = false,
  });

  /// "FirstName LastName", falling back to the username when both are empty.
  String get fullName {
    final full = '$firstName $lastName'.trim();
    return full.isNotEmpty ? full : username;
  }

  bool get isStudent => userType == 'Student';

  bool get isSupervisor => userType == 'Supervisor';

  @override
  List<Object?> get props => [
    id,
    username,
    firstName,
    lastName,
    nationalId,
    mobileNumber,
    userType,
    yearCode,
    employeeId,
    employeePosition,
    employeeEmail,
    alias,
    professionalTitle,
    isSuperAdmin,
    isBlocked,
  ];
}
