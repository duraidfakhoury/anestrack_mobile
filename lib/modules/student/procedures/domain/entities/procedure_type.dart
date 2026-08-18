class ProcedureType {
  final String objectId;
  final String name;
  final bool isActive;

  ProcedureType({
    required this.objectId,
    required this.name,
    required this.isActive,
  });

  /// Local-cache round-trip only (see `ReferenceDataLocalDataSource`) — the
  /// backend response is parsed by `ProcedureTypeModel`, not this.
  factory ProcedureType.fromJson(Map<String, dynamic> json) {
    return ProcedureType(
      objectId: json['objectId'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'objectId': objectId,
    'name': name,
    'isActive': isActive,
  };
}
