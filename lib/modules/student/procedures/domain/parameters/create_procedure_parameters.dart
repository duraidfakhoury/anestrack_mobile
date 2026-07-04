import 'package:equatable/equatable.dart';

/// Parameters for `createProcedure`. Selects the logging flow:
///  - [requestLiveCoSign] true  -> Flow 1: live co-sign at point of care.
///  - [supervisorId] only        -> Flow 2/3: named supervisor confirms async.
///  - [isEmergency] true         -> Flow 3: tagged emergency (still async-confirmed).
class CreateProcedureParameters extends Equatable {
  final String hospitalId;
  final String procedureTypeId;
  final String patientName;
  final String procedureDate;
  final String? supervisorId;
  final String? notes;
  final bool isOffline;
  final bool requestLiveCoSign;
  final bool isEmergency;

  /// Optional non-identifying body photo as a base64 string (no data-URI
  /// prefix). The backend uploads it and sets the +1 body-photo signal.
  final String? photo;

  const CreateProcedureParameters({
    required this.hospitalId,
    required this.procedureTypeId,
    required this.patientName,
    required this.procedureDate,
    this.supervisorId,
    this.notes,
    this.isOffline = false,
    this.requestLiveCoSign = false,
    this.isEmergency = false,
    this.photo,
  });

  Map<String, dynamic> toJson() => {
    'hospitalId': hospitalId,
    'procedureTypeId': procedureTypeId,
    'patientName': patientName,
    'procedureDate': procedureDate,
    if (supervisorId != null && supervisorId!.isNotEmpty)
      'supervisorId': supervisorId,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'isOffline': isOffline,
    if (requestLiveCoSign) 'requestLiveCoSign': true,
    if (isEmergency) 'isEmergency': true,
    if (photo != null && photo!.isNotEmpty) 'photo': photo,
  };

  @override
  List<Object?> get props => [
    hospitalId,
    procedureTypeId,
    patientName,
    procedureDate,
    supervisorId,
    notes,
    isOffline,
    requestLiveCoSign,
    isEmergency,
    photo,
  ];
}
