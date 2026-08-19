class ProcedureType {
  final String id;
  final String name;
  final bool isActive;

  ProcedureType({
    required this.id,
    required this.name,
    required this.isActive,
  });

  /// Local-cache round-trip only (see `ReferenceDataLocalDataSource`) — the
  /// backend response is parsed by `ProcedureTypeModel`, not this.
  factory ProcedureType.fromJson(Map<String, dynamic> json) {
    return ProcedureType(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isActive': isActive,
  };
}
