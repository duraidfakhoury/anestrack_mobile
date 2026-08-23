import 'package:equatable/equatable.dart';

/// One locally-minted attestation queued for `submitOfflineAttestations`.
class OfflineAttestationParameters extends Equatable {
  /// Minted on this device. The idempotency key on this endpoint — must
  /// stay identical across retries (spec rule §8.5).
  final String localId;

  /// Minted on this device. Never logged, never sent anywhere but this
  /// endpoint (spec rule §8.7).
  final String coSignCode;

  /// Device clock at the moment the QR was shown — never user-editable
  /// (spec rule §8.4).
  final String witnessedAt;

  final String? note;

  const OfflineAttestationParameters({
    required this.localId,
    required this.coSignCode,
    required this.witnessedAt,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'coSignCode': coSignCode,
    'witnessedAt': witnessedAt,
    if (note != null && note!.isNotEmpty) 'note': note,
  };

  @override
  List<Object?> get props => [localId, coSignCode, witnessedAt, note];
}
