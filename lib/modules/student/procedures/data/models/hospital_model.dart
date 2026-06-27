class HospitalModel {
  final String objectId;
  final String name;
  final String? address;
  final String? contactInfo;
  final bool isActive;

  HospitalModel({
    required this.objectId,
    required this.name,
    this.address,
    this.contactInfo,
    required this.isActive,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      objectId: json['objectId'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      contactInfo: json['contactInfo'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'name': name,
      'address': address,
      'contactInfo': contactInfo,
      'isActive': isActive,
    };
  }
}
