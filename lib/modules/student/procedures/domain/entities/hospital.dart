class Hospital {
  final String objectId;
  final String name;
  final String? address;
  final String? contactInfo;
  final bool isActive;

  Hospital({
    required this.objectId,
    required this.name,
    this.address,
    this.contactInfo,
    required this.isActive,
  });

  /// Local-cache round-trip only (see `ReferenceDataLocalDataSource`) — the
  /// backend response is parsed by `HospitalModel`, not this.
  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      objectId: json['objectId'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      contactInfo: json['contactInfo'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'objectId': objectId,
    'name': name,
    'address': address,
    'contactInfo': contactInfo,
    'isActive': isActive,
  };
}
