import 'package:anestrack_mobile/modules/student/procedures/data/models/queued_cosigned_procedure_model.dart';

/// Dumb SharedPreferences-list mirror — all CRUD (enqueue/remove/markFailed)
/// is built in [QueuedCosignedProcedureRepositoryImpl] as load-mutate-saveAll.
abstract class QueuedCosignedProcedureLocalDataSource {
  Future<List<QueuedCosignedProcedureModel>> listAll();
  Future<void> saveAll(List<QueuedCosignedProcedureModel> items);
}
