import 'package:anestrack_mobile/modules/supervisor/reviews/data/models/offline_attestation_model.dart';

/// Dumb SharedPreferences-list mirror — all CRUD (mint/remove/markFailed) is
/// built in [OfflineAttestationRepositoryImpl] as load-mutate-saveAll.
abstract class OfflineAttestationLocalDataSource {
  Future<List<OfflineAttestationModel>> listAll();
  Future<void> saveAll(List<OfflineAttestationModel> items);
}
