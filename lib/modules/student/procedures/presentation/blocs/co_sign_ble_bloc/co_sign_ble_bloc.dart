import 'dart:async';

import 'package:anestrack_mobile/core/services/ble/student_code_ble_advertiser.dart';
import 'package:anestrack_mobile/core/services/ble/student_code_ble_protocol.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'co_sign_ble_event.dart';
import 'co_sign_ble_state.dart';

/// Drives the student's BLE co-sign handoff: broadcasts this procedure's
/// co-sign code (see [StudentCodeBleAdvertiser]) for a bounded window so the
/// supervisor's device can pick it up.
///
/// This bloc owns the timing/state machine only. It does **not** call the
/// co-sign API itself — the actual co-sign call happens on the
/// *supervisor's* device (see `LiveCoSignBloc` / `CoSignCodeSheet`),
/// triggered by a human tap there, using the real `coSignCode` (the
/// higher-trust "Verified" tier).
class CoSignBleBloc extends Bloc<CoSignBleEvent, CoSignBleState> {
  final StudentCodeBleAdvertiser advertiser;
  final Logger _logger = Logger();

  Timer? _ticker;
  DateTime? _advertiseDeadline;

  CoSignBleBloc(this.advertiser) : super(const CoSignBleState()) {
    on<StartCoSignBleEvent>(_onStart);
    on<CoSignBleTickEvent>(_onTick);
    on<AdvertisingWindowElapsedEvent>(_onAdvertisingWindowElapsed);
    on<UseQrFallbackEvent>(_onUseQrFallback);
    on<CancelCoSignBleEvent>(_onCancel);
  }

  Future<void> _onStart(
    StartCoSignBleEvent event,
    Emitter<CoSignBleState> emit,
  ) async {
    _logger.i('[BLE] Starting code advertise for procedureId=${event.procedureId}');

    if (event.coSignCode.isEmpty) {
      _logger.w('[BLE] No co-sign code available — switching to QR fallback');
      emit(
        const CoSignBleState().copyWith(
          status: CoSignBleStatus.qrFallback,
          errorMessage: 'missing_co_sign_code',
        ),
      );
      return;
    }

    emit(
      const CoSignBleState().copyWith(
        status: CoSignBleStatus.advertisingCode,
        remaining: kStudentCodeAdvertiseWindow,
      ),
    );

    final started = await advertiser.start(event.coSignCode);
    if (!started) {
      _logger.w('[BLE] Failed to advertise co-sign code — QR fallback');
      add(UseQrFallbackEvent());
      return;
    }

    _advertiseDeadline = DateTime.now().add(kStudentCodeAdvertiseWindow);
    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(CoSignBleTickEvent()),
    );
  }

  void _onTick(CoSignBleTickEvent event, Emitter<CoSignBleState> emit) {
    if (state.status != CoSignBleStatus.advertisingCode) return;
    final deadline = _advertiseDeadline;
    if (deadline == null) return;
    final remaining = deadline.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      add(AdvertisingWindowElapsedEvent());
      return;
    }
    emit(state.copyWith(remaining: remaining));
  }

  Future<void> _onAdvertisingWindowElapsed(
    AdvertisingWindowElapsedEvent event,
    Emitter<CoSignBleState> emit,
  ) async {
    _ticker?.cancel();
    await advertiser.stop();
    _logger.i('[BLE] Code advertise window elapsed');
    emit(state.copyWith(status: CoSignBleStatus.codeSent));
  }

  Future<void> _onUseQrFallback(
    UseQrFallbackEvent event,
    Emitter<CoSignBleState> emit,
  ) async {
    _ticker?.cancel();
    await advertiser.stop();
    emit(state.copyWith(status: CoSignBleStatus.qrFallback));
  }

  Future<void> _onCancel(
    CancelCoSignBleEvent event,
    Emitter<CoSignBleState> emit,
  ) async {
    _ticker?.cancel();
    await advertiser.stop();
  }

  @override
  Future<void> close() async {
    _ticker?.cancel();
    await advertiser.stop();
    return super.close();
  }
}
