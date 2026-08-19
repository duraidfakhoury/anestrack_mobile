import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure_type.dart';

class ProcedureTypeModel extends ProcedureType {
  ProcedureTypeModel({
    required String id,
    required String name,
    required bool isActive,
  }) : super(id: id, name: name, isActive: isActive);

   

  factory ProcedureTypeModel.fromJson(Map<String, dynamic> json) {
    return ProcedureTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isActive': isActive};
  }
}
