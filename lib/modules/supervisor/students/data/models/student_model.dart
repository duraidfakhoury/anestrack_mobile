import 'package:anestrack_mobile/modules/supervisor/students/domain/entities/student.dart';

class StudentModel extends Student {
  const StudentModel({
    required super.objectId,
    required super.username,
    required super.firstName,
    required super.lastName,
    required super.nationalId,
    required super.mobileNumber,
    required super.yearCode,
    required super.isBlocked,
  });

  /// Tolerates both the admin `listUsers`/`User.map` shape
  /// (`objectId`, `FirstName`, `MobileNumber`, ...) and the supervisor-scoped
  /// `listStudents` directory shape (`id`, `firstName`, no PII fields).
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      objectId: (json["id"] ?? json["objectId"]) as String? ?? "",
      username: json["username"] as String? ?? "",
      firstName: (json["firstName"] ?? json["FirstName"]) as String? ?? "",
      lastName: (json["lastName"] ?? json["LastName"]) as String? ?? "",
      nationalId: json["nationalId"] as String? ?? "",
      mobileNumber:
          (json["mobileNumber"] ?? json["MobileNumber"]) as String? ?? "",
      yearCode: (json["yearCode"] as num?)?.toInt() ?? 0,
      isBlocked: json["isBlocked"] as bool? ?? false,
    );
  }
}
