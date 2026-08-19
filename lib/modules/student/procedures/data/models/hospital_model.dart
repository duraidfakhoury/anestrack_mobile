import 'package:anestrack_mobile/modules/student/procedures/domain/entities/hospital.dart';

class HospitalModel extends Hospital {
  HospitalModel({
    required super.id,
    required super.name,
    super.address,
    super.contactInfo,
    required super.isActive,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: (json['objectId'] ?? json['id']) as String? ?? '',
      name: json['name'] as String,
      address: json['address'] as String?,
      contactInfo: json['contactInfo'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': id,
      'name': name,
      'address': address,
      'contactInfo': contactInfo,
      'isActive': isActive,
    };
  }
}
