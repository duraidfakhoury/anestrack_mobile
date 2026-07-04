import 'package:equatable/equatable.dart';

/// A supervisor a student can name when logging a procedure (Flow 2/3).
/// Minimal id/name pair from the backend `listSupervisors` function.
class Supervisor extends Equatable {
  final String objectId;
  final String name;

  const Supervisor({required this.objectId, required this.name});

  @override
  List<Object?> get props => [objectId, name];
}
