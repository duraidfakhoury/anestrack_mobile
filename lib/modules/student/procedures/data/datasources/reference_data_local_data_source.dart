import 'package:anestrack_mobile/modules/student/procedures/domain/entities/hospital.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure_type.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/supervisor.dart';

/// Caches the last successfully fetched hospitals/procedure-types/supervisors
/// lists so the create-procedure dropdowns can still populate when the
/// device is offline. Returns `null` when nothing has ever been cached
/// (distinct from an empty list, which means "we know there are zero").
abstract class ReferenceDataLocalDataSource {
  Future<List<Hospital>?> getCachedHospitals();
  Future<void> cacheHospitals(List<Hospital> hospitals);

  Future<List<ProcedureType>?> getCachedProcedureTypes();
  Future<void> cacheProcedureTypes(List<ProcedureType> procedureTypes);

  Future<List<Supervisor>?> getCachedSupervisors();
  Future<void> cacheSupervisors(List<Supervisor> supervisors);
}
