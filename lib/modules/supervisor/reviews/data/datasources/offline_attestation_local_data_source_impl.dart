import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/data/datasources/offline_attestation_local_data_source.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/data/models/offline_attestation_model.dart';

class OfflineAttestationLocalDataSourceImpl
    implements OfflineAttestationLocalDataSource {
  static const String _key = 'offline_attestations_outbox';

  @override
  Future<List<OfflineAttestationModel>> listAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => OfflineAttestationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveAll(List<OfflineAttestationModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
