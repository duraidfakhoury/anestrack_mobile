/// The two catalog buckets a `ProcedureType.category` value can be.
class ProcedureCategories {
  ProcedureCategories._();

  static const String procedure = 'Procedure';
  static const String technique = 'Technique';
}

class ProcedureType {
  final String id;
  final String name;
  final String? nameAr;
  final String? category; // ProcedureCategories.procedure | .technique
  final bool isActive;

  ProcedureType({
    required this.id,
    required this.name,
    this.nameAr,
    this.category,
    required this.isActive,
  });

  /// Local-cache round-trip only (see `ReferenceDataLocalDataSource`) — the
  /// backend response is parsed by `ProcedureTypeModel`, not this.
  factory ProcedureType.fromJson(Map<String, dynamic> json) {
    return ProcedureType(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      category: json['category'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameAr': nameAr,
    'category': category,
    'isActive': isActive,
  };
}
