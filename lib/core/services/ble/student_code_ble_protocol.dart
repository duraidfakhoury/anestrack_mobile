/// AnesTrack BLE Live Co-Sign protocol. Pure data/validation only: no
/// platform BLE APIs, no networking, no procedure/authorization logic (see
/// CLAUDE.md module boundaries).
///
/// Direction: STUDENT advertises, SUPERVISOR scans. The student's phone
/// broadcasts the procedure's co-sign code; the supervisor's phone (with
/// Live Co-Sign toggled on) scans for it and, on a match, shows the
/// confirmation sheet — see `CoSignBleBloc` / `LiveCoSignBloc`.
///
/// The payload is the co-sign code's raw bytes verbatim (32 hex chars ==
/// [kPayloadLength] bytes) — the backend needs an exact string match, so
/// there is no spare byte to spend on a version/role tag inside the payload
/// itself. A scanner instead recognizes an AnesTrack frame at the
/// delivery-channel level: a dedicated manufacturer ID on Android
/// ([kAnesTrackManufacturerId]), or a dedicated static marker service UUID
/// on iOS ([kAnesTrackServiceUuid]) alongside a second, dynamic UUID
/// carrying the payload bytes (iOS peripheral mode can't send manufacturer
/// data at all — see `StudentCodeBleAdvertiserImpl`).
library;

import 'dart:typed_data';

/// Dedicated 128-bit Service UUID identifying "this is an AnesTrack Live
/// Co-Sign code broadcast". Deliberately NOT built on the Bluetooth SIG base
/// UUID pattern (`XXXXXXXX-0000-1000-8000-00805F9B34FB`) — that pattern is
/// reserved for officially SIG-assigned 16/32-bit UUIDs, not vendor-custom
/// ones.
///
/// This value is a fixed, publicly-known protocol identifier — it carries no
/// secret and never rotates. Only ONE such UUID exists for the whole app.
const String kAnesTrackServiceUuid = 'a17c9b4f-2e6d-4f9a-b3c5-7d8e1f2a6b90';

/// Reserved/prototype manufacturer ID used for the Android-only manufacturer
/// data channel. 0xFFFF is reserved by the Bluetooth SIG for
/// internal/testing use; obtaining a real assigned Company ID is out of
/// scope for this internal app.
const int kAnesTrackManufacturerId = 0xFFFF;

/// Default RSSI floor (dBm) below which a detection is ignored as "too far
/// away to plausibly be the student standing next to the supervisor". This
/// is a proximity nicety only — never treat RSSI as authentication (RSSI is
/// trivially spoofable/variable with orientation, obstruction, tx power).
const int kDefaultMinRssi = -85;

/// The fixed size, in bytes, of a co-sign code (32 hex chars).
const int kPayloadLength = 16;

/// How long the student keeps advertising its co-sign code for one BLE
/// handoff attempt before giving up locally and falling back to the
/// QR/manual code card. This bounds only how long the student's radio stays
/// on for *this attempt* — it is unrelated to the code's own server-side
/// lifetime (`coSignExpiresAt`, ~10 minutes), which the QR/manual fallback
/// can still use for the rest of its life regardless of whether this window
/// elapses. There is no acknowledgement channel in this broadcast-only
/// scheme, so a fixed window (rather than a "supervisor confirmed receipt"
/// signal) is the only way the student side knows when to stop.
const Duration kStudentCodeAdvertiseWindow = Duration(seconds: 60);

/// Parses a 32-hex-char co-sign code into its raw 16 bytes. Returns null if
/// [code] isn't a well-formed 32-hex-digit string (dashes, if present, are
/// tolerated and stripped — co-sign codes themselves have none; this also
/// lets it double as the inverse of [payloadBytesToUuidString] for the iOS
/// delivery channel).
Uint8List? payloadBytesFromUuidString(String code) {
  final hex = code.replaceAll('-', '');
  if (hex.length != 32) return null;
  final bytes = Uint8List(16);
  for (var i = 0; i < 16; i++) {
    final byteHex = hex.substring(i * 2, i * 2 + 2);
    final value = int.tryParse(byteHex, radix: 16);
    if (value == null) return null;
    bytes[i] = value;
  }
  return bytes;
}

/// Formats a 16-byte payload as a standard 8-4-4-4-12 UUID string, for the
/// iOS delivery channel where the code must travel as a second service UUID
/// rather than manufacturer data (iOS peripheral mode can't advertise
/// manufacturer data at all — see `StudentCodeBleAdvertiserImpl`).
String payloadBytesToUuidString(Uint8List bytes) {
  assert(bytes.length == 16);
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20, 32)}';
}

/// Parses a 32-hex-char co-sign code into its raw 16 bytes. Alias of
/// [payloadBytesFromUuidString] under the name callers reason about the
/// code, not a UUID, by.
Uint8List? coSignCodeToBytes(String code) => payloadBytesFromUuidString(code);

/// Reverses [coSignCodeToBytes]: 16 raw bytes -> a 32-char lowercase hex
/// string with no dash grouping, matching the co-sign code's own format
/// (contrast with [payloadBytesToUuidString], which dash-formats bytes for
/// the iOS dynamic-service-UUID delivery channel only, not for the code
/// string itself).
String coSignCodeFromBytes(Uint8List bytes) {
  assert(bytes.length == 16);
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
