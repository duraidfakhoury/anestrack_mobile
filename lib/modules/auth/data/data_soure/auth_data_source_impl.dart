import 'dart:convert';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/core/services/cache_service.dart';
import 'package:anestrack_mobile/modules/auth/data/data_soure/auth_data_source.dart';
import 'package:anestrack_mobile/modules/auth/data/models/login_response_model.dart';
import 'package:anestrack_mobile/modules/auth/data/models/user_model.dart';
import 'package:anestrack_mobile/modules/auth/domain/parameters/login_parameters.dart';
import 'package:logger/logger.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final Logger _logger = Logger();

  @override
  Future<LoginResponseModel> login(LoginParameters parameters) async {
    NetworkResponse response = await NetworkHelper().post(
      ApisUrls().login,
      data: parameters.toJson(),
    );
    await CacheService().setToken(response.data['sessionToken'] as String);
    final loginResponse = LoginResponseModel.fromJson(response.data);
    // Store user info
    await CacheService().setUser(
      jsonEncode((loginResponse.user as UserModel).toJson()),
    );
    await CacheService().setUserRole(loginResponse.user.userType);
    return loginResponse;
  }

  @override
  Future<bool> logout() async {
    try {
      _logger.i("Starting logout process...");
      final response = await NetworkHelper().post(ApisUrls().logout);
      _logger.i("Logout API Response Status: ${response.statusCode}");
      _logger.i("Logout API Response Data: ${response.data}");
      await CacheService().clearAuth();
      _logger.i("Logout successful - cache cleared");
      return true;
    } catch (e) {
      _logger.e("Logout failed with error type: ${e.runtimeType}");
      _logger.e("Logout error details: $e");
      if (e.toString().contains("ServerException")) {
        _logger.e("Server error occurred during logout");
      }
      rethrow;
    }
  }
}
