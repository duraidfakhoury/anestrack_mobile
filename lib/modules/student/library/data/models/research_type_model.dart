import 'package:anestrack_mobile/modules/student/library/domain/entities/research_type.dart';

class ResearchTypeModel extends ResearchType {
  const ResearchTypeModel({
    required super.id,
    required super.name,
    super.isActive,
  });

  factory ResearchTypeModel.fromJson(Map<String, dynamic> json) {
    return ResearchTypeModel(
      id: json['id'] as String? ?? json['objectId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
