import 'dart:convert';

import 'package:equatable/equatable.dart';

/// The bedside QR payload exchanged directly between the supervisor's and
/// student's phones — the server never sees this shape, only the fields it
/// carries once each side uploads independently. See
/// `integration-mobile-offline-cosign.md` §3; both apps must agree on this
/// shape exactly.
class OfflineCoSignQrPayload extends Equatable {
  static const int supportedVersion = 1;

  final int v;

  /// 24 lowercase hex chars. Identifies the bedside event.
  final String localId;

  /// 32 lowercase hex chars. The shared secret.
  final String code;

  /// ISO-8601 UTC with milliseconds, read from the supervisor's device clock
  /// at the moment the QR was shown. Carried here only so the student's app
  /// can warn about a clock disagreement before syncing — it is never sent
  /// to the server directly; the server takes `witnessedAt` from the
  /// supervisor's own `submitOfflineAttestations` call.
  final String witnessedAt;

  const OfflineCoSignQrPayload({
    required this.v,
    required this.localId,
    required this.code,
    required this.witnessedAt,
  });

  DateTime? get witnessedAtDate => DateTime.tryParse(witnessedAt);

  Map<String, dynamic> toJson() => {
    'v': v,
    'localId': localId,
    'code': code,
    'witnessedAt': witnessedAt,
  };

  String encode() => jsonEncode(toJson());

  @override
  List<Object?> get props => [v, localId, code, witnessedAt];
}

enum OfflineCoSignQrDecodeStatus { success, invalidFormat, unsupportedVersion }

/// Result of parsing raw scanned QR text. Decoding never throws — a scan
/// screen must be able to show a friendly message for garbage input rather
/// than crash, and must distinguish "not one of our QR codes" from "this app
/// is out of date and doesn't understand this QR's version" (spec §3: refuse
/// a QR whose `v` you do not know).
class OfflineCoSignQrDecodeResult extends Equatable {
  final OfflineCoSignQrDecodeStatus status;
  final OfflineCoSignQrPayload? payload;
  final int? scannedVersion;

  const OfflineCoSignQrDecodeResult._(
    this.status,
    this.payload,
    this.scannedVersion,
  );

  const OfflineCoSignQrDecodeResult.success(OfflineCoSignQrPayload payload)
    : this._(OfflineCoSignQrDecodeStatus.success, payload, null);

  const OfflineCoSignQrDecodeResult.invalidFormat()
    : this._(OfflineCoSignQrDecodeStatus.invalidFormat, null, null);

  const OfflineCoSignQrDecodeResult.unsupportedVersion(int scannedVersion)
    : this._(
        OfflineCoSignQrDecodeStatus.unsupportedVersion,
        null,
        scannedVersion,
      );

  bool get isSuccess => status == OfflineCoSignQrDecodeStatus.success;

  static final RegExp _hex24 = RegExp(r'^[0-9a-f]{24}$');
  static final RegExp _hex32 = RegExp(r'^[0-9a-f]{32}$');

  static OfflineCoSignQrDecodeResult decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const OfflineCoSignQrDecodeResult.invalidFormat();
      }
      final map = Map<String, dynamic>.from(decoded);

      final v = map['v'];
      if (v is! int) return const OfflineCoSignQrDecodeResult.invalidFormat();
      if (v != OfflineCoSignQrPayload.supportedVersion) {
        return OfflineCoSignQrDecodeResult.unsupportedVersion(v);
      }

      final localId = map['localId'];
      final code = map['code'];
      final witnessedAt = map['witnessedAt'];
      if (localId is! String || code is! String || witnessedAt is! String) {
        return const OfflineCoSignQrDecodeResult.invalidFormat();
      }
      if (!_hex24.hasMatch(localId) || !_hex32.hasMatch(code)) {
        return const OfflineCoSignQrDecodeResult.invalidFormat();
      }
      if (DateTime.tryParse(witnessedAt) == null) {
        return const OfflineCoSignQrDecodeResult.invalidFormat();
      }

      return OfflineCoSignQrDecodeResult.success(
        OfflineCoSignQrPayload(
          v: v,
          localId: localId,
          code: code,
          witnessedAt: witnessedAt,
        ),
      );
    } catch (_) {
      return const OfflineCoSignQrDecodeResult.invalidFormat();
    }
  }

  @override
  List<Object?> get props => [status, payload, scannedVersion];
}
