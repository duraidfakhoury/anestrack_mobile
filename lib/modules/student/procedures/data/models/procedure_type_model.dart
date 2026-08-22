import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure_type.dart';

class ProcedureTypeModel extends ProcedureType {
  ProcedureTypeModel({
    required String id,
    required String name,
    String? nameAr,
    String? category,
    required bool isActive,
  }) : super(
         id: id,
         name: name,
         nameAr: nameAr,
         category: category,
         isActive: isActive,
       );

  factory ProcedureTypeModel.fromJson(Map<String, dynamic> json) {
    return ProcedureTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      category: json['category'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'category': category,
      'isActive': isActive,
    };
  }
}
