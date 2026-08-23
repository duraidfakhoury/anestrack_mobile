import 'dart:math';

/// Cryptographically random lowercase-hex id generator.
///
/// Used for the offline co-sign protocol's `localId`/`code` (see
/// `integration-mobile-offline-cosign.md` §3/§8.2): a guessable code is a
/// forgeable co-sign, so this must never be replaced with `Random()` or any
/// timestamp-seeded generator, even for a "temporary" id elsewhere.
class SecureHexId {
  SecureHexId._();

  static final Random _random = Random.secure();

  /// Returns [byteLength] random bytes as a lowercase hex string
  /// (`byteLength * 2` characters). Use `generate(12)` for a 24-char
  /// `localId` and `generate(16)` for a 32-char `code`.
  static String generate(int byteLength) {
    final buffer = StringBuffer();
    for (var i = 0; i < byteLength; i++) {
      buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
