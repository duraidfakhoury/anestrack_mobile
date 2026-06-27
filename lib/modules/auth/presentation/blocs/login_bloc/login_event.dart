part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginButtonTappedEvent extends LoginEvent {
  final String username;
  final String password;

  const LoginButtonTappedEvent({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [ username, password];
}

