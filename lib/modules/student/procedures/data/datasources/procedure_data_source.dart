import 'package:anestrack_mobile/modules/student/procedures/data/models/procedure_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/models/co_sign_context_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/models/offline_cosign_sync_result_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/models/offline_attestation_submit_result_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/models/offline_cosign_status_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/co_sign_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/confirm_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/evaluation_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/sync_offline_cosigned_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/submit_offline_attestations_parameters.dart';

abstract class ProcedureDataSource {
  Future<List<ProcedureModel>> listProcedures(
    ListProceduresParameters parameters,
  );

  Future<CreateProcedureResult> createProcedure(
    CreateProcedureParameters parameters,
  );

  Future<ProcedureModel> coSignProcedure(CoSignParameters parameters);

  Future<CoSignContextModel> getCoSignContext(String coSignCode);

  /// Student — poll a single procedure's current status (e.g. to detect a
  /// live co-sign completed on the supervisor's device).
  Future<ProcedureModel> getProcedure(String id);

  Future<ProcedureModel> confirmProcedure(
    ConfirmProcedureParameters parameters,
  );

  Future<List<ProcedureModel>> listPendingForSupervisor();

  /// Supervisor — rate the student's performance on a procedure.
  Future<bool> createEvaluation(EvaluationParameters parameters);

  /// Student — upload queued bedside events scanned from a supervisor's QR.
  /// See `integration-mobile-offline-cosign.md` §6.1.
  Future<OfflineCoSignSyncResultModel> syncOfflineCoSignedProcedures(
    SyncOfflineCosignedProceduresParameters parameters,
  );

  /// Supervisor — upload locally-minted attestations. See
  /// `integration-mobile-offline-cosign.md` §6.2.
  Future<OfflineAttestationSubmitResultModel> submitOfflineAttestations(
    SubmitOfflineAttestationsParameters parameters,
  );

  /// Either role — "did my scan/attestation work". See
  /// `integration-mobile-offline-cosign.md` §6.3.
  Future<OfflineCoSignStatusModel> getOfflineCoSignStatus();
}
