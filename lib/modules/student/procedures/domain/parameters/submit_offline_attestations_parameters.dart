import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/offline_attestation_parameters.dart';

/// Request body for `submitOfflineAttestations`.
class SubmitOfflineAttestationsParameters extends Equatable {
  final List<OfflineAttestationParameters> attestations;

  const SubmitOfflineAttestationsParameters(this.attestations);

  Map<String, dynamic> toJson() => {
    'attestations': attestations.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [attestations];
}
