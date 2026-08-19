import 'package:anestrack_mobile/modules/common/profile/domain/entities/current_user.dart';

class CurrentUserModel extends CurrentUser {
  const CurrentUserModel({
    required super.id,
    required super.username,
    required super.firstName,
    required super.lastName,
    required super.nationalId,
    required super.mobileNumber,
    required super.userType,
    super.yearCode,
    super.employeeId,
    super.employeePosition,
    super.employeeEmail,
    super.alias,
    super.professionalTitle,
    super.isSuperAdmin,
    super.isBlocked,
  });

  /// Parses the flat object produced by `User.map` on the backend.
  factory CurrentUserModel.fromJson(Map<String, dynamic> json) {
    return CurrentUserModel(
      id: (json['id'] ?? json['objectId']) as String? ?? '',
      username: json['username'] as String? ?? '',
      firstName: (json['firstName'] ?? json['FirstName']) as String? ?? '',
      lastName: (json['lastName'] ?? json['LastName']) as String? ?? '',
      nationalId: json['nationalId'] as String? ?? '',
      mobileNumber:
          (json['mobileNumber'] ?? json['MobileNumber']) as String? ?? '',
      userType: json['userType'] as String? ?? '',
      yearCode: (json['yearCode'] as num?)?.toInt(),
      employeeId: (json['EmployeeID'] ?? json['employeeId']) as String?,
      employeePosition:
          (json['EmployeePosition'] ?? json['employeePosition']) as String?,
      employeeEmail:
          (json['EmployeeEmail'] ?? json['employeeEmail']) as String?,
      alias: (json['Alias'] ?? json['alias']) as String?,
      professionalTitle: json['professionalTitle'] as String?,
      isSuperAdmin: json['isSuperAdmin'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
    );
  }
}
