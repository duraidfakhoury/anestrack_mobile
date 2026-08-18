import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/reference_data_local_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/hospital.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure_type.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/supervisor.dart';

class ReferenceDataLocalDataSourceImpl implements ReferenceDataLocalDataSource {
  static const String _hospitalsKey = 'cached_hospitals';
  static const String _procedureTypesKey = 'cached_procedure_types';
  static const String _supervisorsKey = 'cached_supervisors';

  Future<List<Map<String, dynamic>>?> _readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> _writeList(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(items));
  }

  @override
  Future<List<Hospital>?> getCachedHospitals() async {
    final raw = await _readList(_hospitalsKey);
    return raw?.map(Hospital.fromJson).toList();
  }

  @override
  Future<void> cacheHospitals(List<Hospital> hospitals) {
    return _writeList(_hospitalsKey, hospitals.map((h) => h.toJson()).toList());
  }

  @override
  Future<List<ProcedureType>?> getCachedProcedureTypes() async {
    final raw = await _readList(_procedureTypesKey);
    return raw?.map(ProcedureType.fromJson).toList();
  }

  @override
  Future<void> cacheProcedureTypes(List<ProcedureType> procedureTypes) {
    return _writeList(
      _procedureTypesKey,
      procedureTypes.map((t) => t.toJson()).toList(),
    );
  }

  @override
  Future<List<Supervisor>?> getCachedSupervisors() async {
    final raw = await _readList(_supervisorsKey);
    return raw?.map(Supervisor.fromJson).toList();
  }

  @override
  Future<void> cacheSupervisors(List<Supervisor> supervisors) {
    return _writeList(
      _supervisorsKey,
      supervisors.map((s) => s.toJson()).toList(),
    );
  }
}
