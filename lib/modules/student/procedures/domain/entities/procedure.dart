import 'package:equatable/equatable.dart';

class Procedure extends Equatable {
  final String id;
  final String procedure;
  final String hospital;
  final String date;
  final String status; // pending, approved, rejected, evaluated
  final String? rating; // excellent, good, acceptable
  final String patientId;
  final String? createdAt;
  final String? updatedAt;

  const Procedure({
    required this.id,
    required this.procedure,
    required this.hospital,
    required this.date,
    required this.status,
    this.rating,
    required this.patientId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    procedure,
    hospital,
    date,
    status,
    rating,
    patientId,
    createdAt,
    updatedAt,
  ];
}
