part of 'logout_bloc.dart';

sealed class LogoutEvent extends Equatable {
  const LogoutEvent();

  @override
  List<Object> get props => [];
}

class LogoutRequestedEvent extends LogoutEvent {
  const LogoutRequestedEvent();
}
