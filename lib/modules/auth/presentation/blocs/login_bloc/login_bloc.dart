import 'package:anestrack_mobile/core/services/notifications/firebase_messaging_service.dart';
import 'package:anestrack_mobile/core/services/procedure_sync/procedure_sync_service.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/auth/domain/entity/login_response.dart';
import 'package:anestrack_mobile/modules/auth/domain/parameters/login_parameters.dart';
import 'package:anestrack_mobile/modules/auth/domain/repository/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';

class LoginBloc extends Bloc<LoginEvent, BaseState<LoginResponse>> {
  final AuthRepository authRepository;

  LoginBloc(this.authRepository) : super(const BaseState<LoginResponse>()) {
    on<LoginButtonTappedEvent>(_onLoginButtonTapped);
  }

  Future<void> _onLoginButtonTapped(
    LoginButtonTappedEvent event,
    Emitter<BaseState<LoginResponse>> emit,
  ) async {
    emit(state.loading());

    final parameters = LoginParameters(
      username: event.username,
      password: event.password,
    );

    final result = await authRepository.login(parameters);

    result.fold(
      (failure) => emit(state.error(failure)),
      (loginResponse) {
        // Flush anything queued while logged out (or by a previous
        // session) — fire-and-forget, must not block the login flow.
        sl<ProcedureSyncService>().syncNow();
        // Register this device for push notifications now that a session
        // token exists — also fire-and-forget, same reasoning.
        FirebaseMessagingService.instance.registerCurrentDeviceIfLoggedIn();
        emit(state.successNotNull(loginResponse));
      },
    );
  }
}
