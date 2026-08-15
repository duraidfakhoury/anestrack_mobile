import 'dart:async';

import 'package:anestrack_mobile/core/services/ble/supervisor_code_ble_scanner.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

enum LiveCoSignStatus {
  off,
  starting,
  on,
  bluetoothUnavailable,
  permissionDenied,
  error,
}

class LiveCoSignState extends Equatable {
  final LiveCoSignStatus status;

  /// A nearby student's co-sign code, decoded over BLE, awaiting UI handling
  /// (opening `CoSignCodeSheet`). Null-ness is the de-dup gate: while a
  /// detection is pending handling, further detections (from the same
  /// student re-appearing on the next scan tick, or a different student) are
  /// dropped — see `LiveCoSignBloc._onStudentCodeDetected`.
  final StudentCodeDetection? detectedCode;

  const LiveCoSignState({this.status = LiveCoSignStatus.off, this.detectedCode});

  LiveCoSignState copyWith({
    LiveCoSignStatus? status,
    StudentCodeDetection? detectedCode,
    bool clearDetectedCode = false,
  }) => LiveCoSignState(
    status: status ?? this.status,
    detectedCode: clearDetectedCode ? null : (detectedCode ?? this.detectedCode),
  );

  bool get isOn => status == LiveCoSignStatus.on;

  @override
  List<Object?> get props => [status, detectedCode];
}

abstract class LiveCoSignEvent {}

/// User flipped the "Live Co-Sign" switch.
class ToggleLiveCoSignEvent extends LiveCoSignEvent {
  final bool enabled;
  ToggleLiveCoSignEvent(this.enabled);
}

/// Logout (or any other "must stop scanning now" trigger) must always stop
/// scanning, regardless of the current UI state.
class StopLiveCoSignEvent extends LiveCoSignEvent {}

/// Internal: a nearby student's co-sign code was decoded from BLE.
class StudentCodeDetectedEvent extends LiveCoSignEvent {
  final StudentCodeDetection detection;
  StudentCodeDetectedEvent(this.detection);
}

/// UI finished handling [LiveCoSignState.detectedCode] (the sheet closed) —
/// reopens the de-dup gate for the next detection.
class StudentCodeHandledEvent extends LiveCoSignEvent {}

/// Internal: the scan stream reported an error after scanning had already
/// (optimistically) been reported as started.
class ScanFailedEvent extends LiveCoSignEvent {
  final String message;
  ScanFailedEvent(this.message);
}

/// Supervisor-side "Live Co-Sign" toggle. Owns the ON/OFF lifecycle around
/// [SupervisorCodeBleScanner]: while on, this device scans for a nearby
/// student's co-sign code broadcast (sent once that student's own phone has
/// requested live co-sign for a procedure — see `CoSignBleBloc`).
/// Permission/Bluetooth checks happen here; scanning itself happens in that
/// service. Never calls the co-sign API or decides authorization itself —
/// a detected code only surfaces as [LiveCoSignState.detectedCode] for the
/// UI to open `CoSignCodeSheet`, where a human confirms.
///
/// Scanning is only ever active while explicitly turned on — never just
/// because the supervisor is logged in — and must stop on logout.
class LiveCoSignBloc extends Bloc<LiveCoSignEvent, LiveCoSignState> {
  final SupervisorCodeBleScanner codeScanner;
  final Logger _logger = Logger();

  StreamSubscription<StudentCodeDetection>? _codeScanSubscription;

  LiveCoSignBloc(this.codeScanner) : super(const LiveCoSignState()) {
    on<ToggleLiveCoSignEvent>(_onToggle);
    on<StopLiveCoSignEvent>(_onStop);
    on<StudentCodeDetectedEvent>(_onStudentCodeDetected);
    on<StudentCodeHandledEvent>(_onStudentCodeHandled);
    on<ScanFailedEvent>(_onScanFailed);
  }

  Future<void> _onToggle(
    ToggleLiveCoSignEvent event,
    Emitter<LiveCoSignState> emit,
  ) async {
    if (event.enabled) {
      await _start(emit);
    } else {
      await _stop(emit);
    }
  }

  Future<void> _start(Emitter<LiveCoSignState> emit) async {
    emit(state.copyWith(status: LiveCoSignStatus.starting));

    final permitted = await codeScanner.requestRequiredPermissions();
    if (isClosed) return;
    if (!permitted) {
      _logger.w('[BLE] Live Co-Sign: permission denied');
      emit(state.copyWith(status: LiveCoSignStatus.permissionDenied));
      return;
    }

    _logger.i('[BLE] Supervisor Live Co-Sign enabled — scanning for student codes');
    await _codeScanSubscription?.cancel();
    _codeScanSubscription = codeScanner.startScanning().listen(
      (detection) => add(StudentCodeDetectedEvent(detection)),
      onError: (Object error) {
        _logger.w('[BLE] Student code scan error: $error');
        add(ScanFailedEvent(error.toString()));
      },
    );

    emit(state.copyWith(status: LiveCoSignStatus.on));
  }

  Future<void> _stop(Emitter<LiveCoSignState> emit) async {
    await _codeScanSubscription?.cancel();
    _codeScanSubscription = null;
    await codeScanner.stopScanning();
    emit(state.copyWith(status: LiveCoSignStatus.off, clearDetectedCode: true));
  }

  Future<void> _onStop(
    StopLiveCoSignEvent event,
    Emitter<LiveCoSignState> emit,
  ) async {
    await _stop(emit);
  }

  void _onScanFailed(ScanFailedEvent event, Emitter<LiveCoSignState> emit) {
    if (state.status != LiveCoSignStatus.on) return;
    final unavailable = event.message.toLowerCase().contains('disabled');
    emit(
      state.copyWith(
        status: unavailable
            ? LiveCoSignStatus.bluetoothUnavailable
            : LiveCoSignStatus.error,
      ),
    );
  }

  void _onStudentCodeDetected(
    StudentCodeDetectedEvent event,
    Emitter<LiveCoSignState> emit,
  ) {
    if (state.detectedCode != null) return;
    emit(state.copyWith(detectedCode: event.detection));
  }

  void _onStudentCodeHandled(
    StudentCodeHandledEvent event,
    Emitter<LiveCoSignState> emit,
  ) {
    emit(state.copyWith(clearDetectedCode: true));
  }

  @override
  Future<void> close() async {
    await _codeScanSubscription?.cancel();
    _codeScanSubscription = null;
    await codeScanner.dispose();
    return super.close();
  }
}
