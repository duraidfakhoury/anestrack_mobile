import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/offline_cosigned_procedure_parameters.dart';

/// Request body for `syncOfflineCoSignedProcedures` — one request can carry
/// many independent bedside events; each gets its own result row.
class SyncOfflineCosignedProceduresParameters extends Equatable {
  final List<OfflineCosignedProcedureParameters> procedures;

  const SyncOfflineCosignedProceduresParameters(this.procedures);

  Map<String, dynamic> toJson() => {
    'procedures': procedures.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [procedures];
}
