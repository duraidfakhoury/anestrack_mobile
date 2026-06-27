class ProcedureTypeModel {
  final String objectId;
  final String name;
  final bool isActive;

  ProcedureTypeModel({
    required this.objectId,
    required this.name,
    required this.isActive,
  });

  factory ProcedureTypeModel.fromJson(Map<String, dynamic> json) {
    return ProcedureTypeModel(
      objectId: json['objectId'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'objectId': objectId, 'name': name, 'isActive': isActive};
  }
}
