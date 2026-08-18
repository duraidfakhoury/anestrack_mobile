import 'package:anestrack_mobile/modules/student/procedures/data/models/pending_procedure_model.dart';

/// Dumb SharedPreferences-list mirror — all CRUD (enqueue/remove/markFailed)
/// is built in [PendingProcedureRepositoryImpl] as load-mutate-saveAll.
abstract class PendingProcedureLocalDataSource {
  Future<List<PendingProcedureModel>> listAll();
  Future<void> saveAll(List<PendingProcedureModel> items);
}
