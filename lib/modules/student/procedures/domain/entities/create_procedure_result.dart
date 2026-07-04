import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';

/// The result of logging a procedure. When the student requested a live co-sign
/// (Flow 1), the backend returns a one-time [coSignCode] alongside the procedure.
/// The code is the shared secret carried phone-to-phone to the supervisor.
class CreateProcedureResult extends Equatable {
  final Procedure procedure;

  /// Present ONLY when `requestLiveCoSign: true` was sent. This is the single
  /// time the code is ever returned — it must be handed to the supervisor
  /// (over BLE/QR/manual) before the 10-minute window lapses.
  final String? coSignCode;

  const CreateProcedureResult({required this.procedure, this.coSignCode});

  bool get requiresLiveCoSign => coSignCode != null;

  @override
  List<Object?> get props => [procedure, coSignCode];
}
