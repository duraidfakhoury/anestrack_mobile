import 'package:anestrack_mobile/modules/student/procedures/domain/entities/supervisor.dart';

class SupervisorModel extends Supervisor {
  const SupervisorModel({required super.id, required super.username, required super.firstName, required super.lastName, required super.fullName, required super.userType});

  factory SupervisorModel.fromJson(Map<String, dynamic> json) {
    return SupervisorModel(
      id: (json['id'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      firstName: (json['firstName'] as String?) ?? '',
      lastName: (json['lastName'] as String?) ?? '',
      fullName: (json['fullName'] as String?) ?? '',
      userType: (json['userType'] as String?) ?? '',
    );
  }
}
          
