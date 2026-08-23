import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/queued_cosigned_procedure_local_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/models/queued_cosigned_procedure_model.dart';

class QueuedCosignedProcedureLocalDataSourceImpl
    implements QueuedCosignedProcedureLocalDataSource {
  static const String _key = 'queued_cosigned_procedures';

  @override
  Future<List<QueuedCosignedProcedureModel>> listAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map(
          (e) => QueuedCosignedProcedureModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> saveAll(List<QueuedCosignedProcedureModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
