import 'package:anestrack_mobile/modules/auth/domain/entity/user.dart';
import 'package:equatable/equatable.dart';

class LoginResponse extends Equatable {
  final String sessionToken;
  final String objectId;
  final String className;
  final String type;
  final User user;

  const LoginResponse({
    required this.sessionToken,
    required this.objectId,
    required this.className,
    required this.type,
    required this.user,
  });

  @override
  List<Object?> get props => [sessionToken, user, objectId, className, type];
}
