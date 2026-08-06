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

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      objectId: json["objectId"] as String? ?? "",
      username: json["username"] as String? ?? "",
      firstName: json["FirstName"] as String? ?? "",
      lastName: json["LastName"] as String? ?? "",
      nationalId: json["nationalId"] as String? ?? "",
      mobileNumber: json["MobileNumber"] as String? ?? "",
      yearCode: json["yearCode"] as int? ?? 0,
      isBlocked: json["isBlocked"] as bool? ?? false,
    );
  }
}
