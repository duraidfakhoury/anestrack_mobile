import 'package:anestrack_mobile/core/services/ble/supervisor_code_ble_scanner.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/auth/domain/repository/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'logout_event.dart';

class LogoutBloc extends Bloc<LogoutEvent, BaseState<bool>> {
  final AuthRepository authRepository;
  final SupervisorCodeBleScanner codeScanner;

  LogoutBloc(this.authRepository, this.codeScanner)
    : super(const BaseState<bool>()) {
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<BaseState<bool>> emit,
  ) async {
    emit(state.loading());

    // Live Co-Sign scanning must never outlive the session it belongs to.
    await codeScanner.stopScanning();

    final result = await authRepository.logout();

    result.fold(
      (failure) => emit(state.error(failure)),
      (value) => emit(state.successNotNull(value)),
    );
  }
}
