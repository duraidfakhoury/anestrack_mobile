import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';

class ProcedureModel extends Procedure {
  const ProcedureModel({
    required super.id,
    required super.procedure,
    required super.hospital,
    required super.date,
    required super.status,
    super.rating,
    required super.patientId,
    super.createdAt,
    super.updatedAt,
  });

  factory ProcedureModel.fromJson(Map<String, dynamic> json) {
    return ProcedureModel(
      id: json['objectId'] as String? ?? '',
      procedure: json['procedure'] as String? ?? '',
      hospital: json['hospital'] as String? ?? '',
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      rating: json['rating'] as String?,
      patientId: json['patientId'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'objectId': id,
    'procedure': procedure,
    'hospital': hospital,
    'date': date,
    'status': status,
    if (rating != null) 'rating': rating,
    'patientId': patientId,
    if (createdAt != null) 'createdAt': createdAt,
    if (updatedAt != null) 'updatedAt': updatedAt,
  };
}
