import 'package:equatable/equatable.dart';

class CreateProcedureParameters extends Equatable {
  final String hospitalId;
  final String procedureTypeId;
  final String? supervisorId;
  final String patientName;
  final String procedureDate;
  final String? notes;
  final bool? isOffline;

  const CreateProcedureParameters({
    required this.hospitalId,
    required this.procedureTypeId,
    this.supervisorId,
    required this.patientName ,
    required this.procedureDate,
    this.notes,
    this.isOffline = false,
  });

  Map<String, dynamic> toJson() => {
    'hospitalId': hospitalId,
    'procedureTypeId': procedureTypeId,
    'supervisorId': supervisorId,
    'patientName': patientName,
    'procedureDate': procedureDate,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'isOffline': isOffline ?? false,
  };

  @override
  List<Object?> get props => [
    hospitalId,
    procedureTypeId,
    supervisorId,
    patientName,
    procedureDate,
    notes,
    isOffline,
  ];
}
