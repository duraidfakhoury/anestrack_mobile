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
      (loginResponse) => emit(state.successNotNull(loginResponse)),
    );
  }
}
