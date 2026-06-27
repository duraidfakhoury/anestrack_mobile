import 'package:anestrack_mobile/modules/auth/data/models/login_response_model.dart';

import 'package:anestrack_mobile/modules/auth/domain/parameters/login_parameters.dart';

abstract class AuthDataSource {
  Future<LoginResponseModel> login(LoginParameters parameters);
  Future<bool> logout();
}
