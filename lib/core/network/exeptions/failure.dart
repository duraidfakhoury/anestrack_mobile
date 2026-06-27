import 'package:equatable/equatable.dart';


/// The [Failure] expresses failures in the application.
/// if an [Exception] occurs, the Exception will be dealt with to turn one or more EXceptions into a Failure based on the application’s logic.
class Failure extends Equatable {
  final String message;
  final int? statusCode;
  const Failure(this.message, {this.statusCode});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {required super.statusCode});

  @override
  String toString() => '${statusCode ?? ''} $message';
}

class NoInternetFailure extends Failure {
  const NoInternetFailure() : super("No Internet Connection ");
}

//! un known Failure
class UnknownFailure extends Failure {
  const UnknownFailure() : super("Unkwon Failure");
}

//!  app version is invalid
class ForceUpdateFailure extends Failure {
  const ForceUpdateFailure() : super("App Version Too Old , Download the latest Version ");
}

//! app is under maintain or check app version failed
class AppUnderMaintenanceFailure extends Failure {
  const AppUnderMaintenanceFailure() : super("The App is under maintenence , Please Try Again Later ");
}

//! refresh token is invalid
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure() : super("Seesion Expired , Please relogin To Your Account");
}

//! can not parse response
class ParsingFailure extends Failure {
  final String parsingMessage;
  const ParsingFailure({required this.parsingMessage})
      : super('Parse Error  ($parsingMessage)');
}
