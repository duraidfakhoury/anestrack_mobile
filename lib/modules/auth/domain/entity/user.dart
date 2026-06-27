import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String username;
  final String userType;
  final String firstName;
  final String lastName;
  final String email;
  final String nationalId;
  final String mobileNumber;
  final int yearCode;
  final ACL acl;

  const User({
    required this.username,
    required this.userType,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.nationalId,
    required this.mobileNumber,
    required this.yearCode,
    required this.acl,
  });

  @override
  List<Object?> get props => [ username, userType, firstName, lastName, email, nationalId, mobileNumber, yearCode, acl];
}

class ACL extends Equatable {
  final bool read;
  final bool write;

  const ACL({required this.read, required this.write});

  @override
  List<Object?> get props => [read, write];
}


  
