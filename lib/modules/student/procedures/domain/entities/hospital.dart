class Hospital {
  final String id;
  final String name;
  final String? address;
  final String? contactInfo;
  final bool isActive;

  Hospital({
    required this.id,
    required this.name,
    this.address,
    this.contactInfo,
    required this.isActive,
  });

  /// Local-cache round-trip only (see `ReferenceDataLocalDataSource`) — the
  /// backend response is parsed by `HospitalModel`, not this.
  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      contactInfo: json['contactInfo'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'contactInfo': contactInfo,
    'isActive': isActive,
  };
}
