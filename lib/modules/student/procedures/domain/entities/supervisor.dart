import 'package:equatable/equatable.dart';

/// A supervisor a student can name when logging a procedure (Flow 2/3).
/// Matches the backend supervisor JSON structure.
class Supervisor extends Equatable {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String fullName;
  final String userType;

  const Supervisor({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.userType,
  });

  /// Factory constructor to parse JSON response from the API
  factory Supervisor.fromJson(Map<String, dynamic> json) {
    return Supervisor(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      userType: json['userType'] as String? ?? '',
    );
  }

  /// Convert Supervisor instance back to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'userType': userType,
    };
  }

  @override
  List<Object?> get props => [
        id,
        username,
        firstName,
        lastName,
        fullName,
        userType,
      ];
}