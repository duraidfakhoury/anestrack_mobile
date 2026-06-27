import 'package:anestrack_mobile/modules/auth/domain/entity/login_response.dart';
import 'user_model.dart';

class LoginResponseModel extends LoginResponse {
  const LoginResponseModel({
    required UserModel super.user,
    required super.sessionToken,
    required super.objectId,
    required super.className,
    required super.type,
  });

factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
  return LoginResponseModel(
    sessionToken: json['sessionToken'] as String? ?? "",
    objectId: json['objectId'] as String? ?? "",
    className: json['className'] as String? ?? "",
    type: json['__type'] as String? ?? "",
    user: UserModel.fromJson(json),
  );
}

  Map<String, dynamic> toJson() => {
    "sessionToken": sessionToken,
    "objectId": objectId,
    "className": className,
    "__type": type,
    "user": (user as UserModel).toJson(),
  };
}
