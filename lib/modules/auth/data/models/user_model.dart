import 'package:anestrack_mobile/modules/auth/domain/entity/user.dart';

class UserModel extends User {
  const UserModel({
    required super.email,
    required super.username,
    required super.userType,
    required super.firstName,
    required super.lastName,
    required super.nationalId,
    required super.mobileNumber,
    required super.yearCode,
    required super.acl,
  });

factory UserModel.fromJson(Map<String, dynamic> json) {

  final aclData = json["ACL"] as Map<String, dynamic>;
  final firstAcl = aclData.values.first as Map<String, dynamic>;

  return UserModel(
    email: json["email"] as String? ?? "",
    username: json["username"] as String? ?? "",
    userType: json["userType"] as String? ?? "",
    firstName: json["FirstName"] as String? ?? "",
    lastName: json["LastName"] as String? ?? "",
    nationalId: json["nationalId"] as String? ?? "",
    mobileNumber: json["MobileNumber"] as String? ?? "",
    yearCode: json["yearCode"] as int? ?? 0,
    acl: ACL(
      read: firstAcl["read"] as bool? ?? false,
      write: firstAcl["write"] as bool? ?? false,
    ),
  );
}

  Map<String, dynamic> toJson() => {
    "username": username,
    "userType": userType,
    "FirstName": firstName,
    "LastName": lastName,
    "nationalId": nationalId,
    "MobileNumber": mobileNumber,
    "yearCode": yearCode,
    "ACL": {"read": acl.read, "write": acl.write},
  };
}
