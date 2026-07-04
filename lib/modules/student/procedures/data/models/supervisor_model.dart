import 'package:anestrack_mobile/modules/student/procedures/domain/entities/supervisor.dart';

class SupervisorModel extends Supervisor {
  const SupervisorModel({required super.objectId, required super.name});

  factory SupervisorModel.fromJson(Map<String, dynamic> json) {
    final first = (json['FirstName'] as String?) ?? '';
    final last = (json['LastName'] as String?) ?? '';
    final composed = '$first $last'.trim();
    return SupervisorModel(
      objectId: (json['objectId'] as String?) ?? '',
      // listSupervisors already returns a composed `name`; fall back to the
      // first/last pair if a raw user object is ever passed instead.
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String).trim()
          : composed,
    );
  }
}
