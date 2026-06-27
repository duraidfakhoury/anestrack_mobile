import 'package:anestrack_mobile/core/config/app_config.dart';
import 'package:anestrack_mobile/core/network/base_headers.dart';
import 'package:anestrack_mobile/core/services/cache_service.dart';

/// This class [AppHeaders] identifier represents the headers that can be sent to the server side
/// this class should have all headers in your application
/// [defaultHeaders] expresses the base headers used to interact with the server side
///
/// You can also define which headers could be used in the application

class AppHeaders extends BaseHeaders {
  static AppHeaders? _instance;
  AppHeaders._();
  factory AppHeaders() => _instance ??= AppHeaders._();

  @override
  Map<String, String> get defaultHeaders => {
    "X-Parse-Application-Id": AppConfig().xParseApplicationId,
    "X-Parse-REST-API-Key": AppConfig().xParseRestApiKey,
    if (CacheService().hasToken) "X-Parse-Session-Token": CacheService().token,
    "accept": "application/json",
    "Content-Type": "application/json",
  };
}
