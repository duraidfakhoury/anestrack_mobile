import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/pending_procedure_local_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/models/pending_procedure_model.dart';

class PendingProcedureLocalDataSourceImpl
    implements PendingProcedureLocalDataSource {
  static const String _key = 'pending_procedures';

  @override
  Future<List<PendingProcedureModel>> listAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => PendingProcedureModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveAll(List<PendingProcedureModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
