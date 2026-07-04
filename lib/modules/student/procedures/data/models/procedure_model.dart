import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';

/// Maps a Parse-serialized `Procedure` object into the domain entity.
///
/// The backend returns standard Parse encoding: `Date` fields as
/// `{"__type":"Date","iso":...}`, un-included pointers as
/// `{"__type":"Pointer",...}`, and included pointers as full nested objects.
/// These helpers tolerate all of those shapes.
class ProcedureModel extends Procedure {
  const ProcedureModel({
    required super.id,
    required super.status,
    required super.patientName,
    super.procedureDate,
    super.createdAt,
    super.notes,
    super.isOffline,
    super.isEmergency,
    super.hospitalId,
    super.hospitalName,
    super.procedureTypeId,
    super.procedureTypeName,
    super.studentId,
    super.studentName,
    super.supervisorId,
    super.supervisorName,
    super.reliabilityScore,
    super.assuranceLevel,
    super.reliabilityFlags,
    super.liveCoSign,
    super.proximityVerified,
    super.asyncConfirmed,
    super.bodyPhoto,
    super.coSignStatus,
    super.coSignExpiresAt,
    super.confirmationStatus,
    super.confirmationDeadline,
  });

  factory ProcedureModel.fromJson(Map<String, dynamic> json) {
    return ProcedureModel(
      id: (json['objectId'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'Pending',
      patientName: (json['patientName'] as String?) ?? '',
      procedureDate: parseDate(json['procedureDate']),
      createdAt: parseDate(json['createdAt']),
      notes: json['notes'] as String?,
      isOffline: json['isOffline'] as bool? ?? false,
      isEmergency: json['isEmergency'] as bool? ?? false,
      hospitalId: pointerId(json['hospital']),
      hospitalName: pointerField(json['hospital'], 'name'),
      procedureTypeId: pointerId(json['procedureType']),
      procedureTypeName: pointerField(json['procedureType'], 'name'),
      studentId: pointerId(json['student']),
      studentName: userFullName(json['student']),
      supervisorId: pointerId(json['supervisor']),
      supervisorName: userFullName(json['supervisor']),
      reliabilityScore: (json['reliabilityScore'] as num?)?.toInt(),
      assuranceLevel: json['assuranceLevel'] as String?,
      reliabilityFlags:
          (json['reliabilityFlags'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      liveCoSign: json['liveCoSign'] as bool? ?? false,
      proximityVerified: json['proximityVerified'] as bool? ?? false,
      asyncConfirmed: json['asyncConfirmed'] as bool? ?? false,
      bodyPhoto: json['bodyPhoto'] as bool? ?? false,
      coSignStatus: json['coSignStatus'] as String?,
      coSignExpiresAt: parseDate(json['coSignExpiresAt']),
      confirmationStatus: json['confirmationStatus'] as String?,
      confirmationDeadline: parseDate(json['confirmationDeadline']),
    );
  }

  /// Parse `Date` field -> ISO string. Accepts `{__type:Date, iso}` or a plain
  /// ISO string (as `createdAt`/`updatedAt` arrive from toJSON).
  static String? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map && value['iso'] != null) return value['iso'] as String;
    return null;
  }

  /// objectId of a pointer, whether included (nested object) or a bare pointer.
  static String? pointerId(dynamic value) {
    if (value is Map && value['objectId'] != null) {
      return value['objectId'] as String;
    }
    if (value is String) return value; // already an id
    return null;
  }

  /// A scalar field of an *included* pointer (null for a bare pointer).
  static String? pointerField(dynamic value, String field) {
    if (value is Map && value[field] != null) return value[field] as String;
    return null;
  }

  /// "FirstName LastName" of an included `_User` pointer.
  static String? userFullName(dynamic value) {
    if (value is Map) {
      final first = (value['FirstName'] as String?) ?? '';
      final last = (value['LastName'] as String?) ?? '';
      final full = '$first $last'.trim();
      if (full.isNotEmpty) return full;
    }
    return null;
  }
}
