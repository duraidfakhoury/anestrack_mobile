abstract class CoSignBleEvent {}

/// Starts broadcasting this procedure's co-sign code over BLE. Fired once,
/// right after the procedure is submitted.
class StartCoSignBleEvent extends CoSignBleEvent {
  final String procedureId;
  final String coSignCode;
  StartCoSignBleEvent(this.procedureId, this.coSignCode);
}

/// Internal: one-second countdown tick during the advertise window.
class CoSignBleTickEvent extends CoSignBleEvent {}

/// Internal: the code-advertise window elapsed. There is no acknowledgement
/// channel in this broadcast-only scheme, so this is the only signal the
/// student side has that the handoff attempt is "done" — it does not mean
/// the supervisor actually received or confirmed the code.
class AdvertisingWindowElapsedEvent extends CoSignBleEvent {}

/// User tapped "Use QR instead" — skip the rest of the BLE flow.
class UseQrFallbackEvent extends CoSignBleEvent {}

/// Screen is leaving — stop advertising/timers without changing UI state.
class CancelCoSignBleEvent extends CoSignBleEvent {}
