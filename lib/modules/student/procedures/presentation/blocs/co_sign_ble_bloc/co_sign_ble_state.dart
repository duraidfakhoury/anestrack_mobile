import 'package:equatable/equatable.dart';

/// Explicit state machine for the student's BLE co-sign handoff: this
/// device broadcasts the procedure's co-sign code for the supervisor's
/// device to pick up. Kept as one linear enum rather than scattered
/// timers/booleans so the screen can render each step directly.
enum CoSignBleStatus { idle, advertisingCode, codeSent, qrFallback, error }

class CoSignBleState extends Equatable {
  final CoSignBleStatus status;

  /// Countdown remaining in the advertise window, while [status] is
  /// [CoSignBleStatus.advertisingCode].
  final Duration remaining;

  /// Short reason code for a fallback path (e.g. 'permission_denied',
  /// 'not_ready', 'advertise_failed') — kept for debug/QA visibility, not
  /// shown verbatim to the user.
  final String? errorMessage;

  const CoSignBleState({
    this.status = CoSignBleStatus.idle,
    this.remaining = Duration.zero,
    this.errorMessage,
  });

  CoSignBleState copyWith({
    CoSignBleStatus? status,
    Duration? remaining,
    String? errorMessage,
  }) {
    return CoSignBleState(
      status: status ?? this.status,
      remaining: remaining ?? this.remaining,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, remaining, errorMessage];
}
