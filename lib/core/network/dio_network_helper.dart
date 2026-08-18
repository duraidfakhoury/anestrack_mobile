import 'package:anestrack_mobile/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/network/network_errors_handler.dart';

import 'network_helper.dart';

class DioNetworkHelper extends NetworkHelper {
  DioNetworkHelper._() : super.create();
  static DioNetworkHelper? _instance;
  factory DioNetworkHelper() => _instance ??= DioNetworkHelper._();

  // Plain Dio() has no timeout at all, so a poor connection could hang a
  // request indefinitely with the UI stuck on a loading state. Capping it
  // means a stalled request fails predictably (with no response, i.e. the
  // same NoInternetException path as an outright disconnect) instead of
  // hanging forever.
  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  Logger logger = Logger();
  Map<String, dynamic> _buildHeaders(Map<String, dynamic>? headers) {
    final merged = <String, dynamic>{
      ...this.headers.defaultHeaders,
      if (headers != null) ...headers,
    };
    merged["X-Parse-Application-Id"] = AppConfig().xParseApplicationId;
    merged["X-Parse-REST-API-Key"] = AppConfig().xParseRestApiKey;
    merged["accept"] = "application/json";
    merged["Content-Type"] = "application/json";
    return merged;
  }

  // on post request
  @override
  Future<NetworkResponse> post(
    String url, {
    Map<String, dynamic>? headers,
    Object? data,
    Future<NetworkResponse> Function(RequestFunction function)?
    exceptionThrower,
  }) async {
    logger.d(
      "============== POST METHOD ================= \n URL: ($url) \n ${data != null ? "Parameters: $data" : ''}",
    );
    if (headers != null) logger.i(headers);

    final process = _dio.post(
      url,
      data: data,
      options: Options(headers: _buildHeaders(headers)),
    );

    return exceptionThrower?.call(() => process) ??
        handler?.defaultExceptionThrower(() => process) ??
        NetworkErrorsHandler().defaultExceptionThrower(() => process);
  }

  // on put request
  @override
  Future<NetworkResponse> put(
    String url, {
    Map<String, dynamic>? headers,
    Object? data,
    Future<NetworkResponse> Function(RequestFunction function)?
    exceptionThrower,
  }) async {
    logger.d(
      "============== PUt METHOD ================= \n URL: ($url) \n ${data != null ? "Parameters: $data" : ''}",
    );
    if (headers != null) logger.i(headers);

    final process = _dio.put(
      url,
      data: data,
      options: Options(headers: _buildHeaders(headers)),
    );

    return exceptionThrower?.call(() => process) ??
        handler?.defaultExceptionThrower(() => process) ??
        NetworkErrorsHandler().defaultExceptionThrower(() => process);
  }

  // on delete request
  @override
  Future<NetworkResponse> delete(
    String url, {
    Map<String, dynamic>? headers,
    Object? data,
    Future<NetworkResponse> Function(RequestFunction function)?
    exceptionThrower,
  }) async {
    logger.d(
      "============== DELETE METHOD ================= \n URL: ($url) \n ${data != null ? "Parameters: $data" : ''}",
    );
    if (headers != null) logger.i(headers);

    final process = _dio.delete(
      url,
      data: data,
      options: Options(headers: _buildHeaders(headers)),
    );

    return exceptionThrower?.call(() => process) ??
        handler?.defaultExceptionThrower(() => process) ??
        NetworkErrorsHandler().defaultExceptionThrower(() => process);
  }

  // on get request
  @override
  Future<NetworkResponse> get(
    String url, {
    Map<String, dynamic>? headers,
    Object? data,
    Future<NetworkResponse> Function(RequestFunction function)?
    exceptionThrower,
  }) async {
    logger.d(
      "============== GET METHOD ================= \n URL: ($url) \n ${data != null ? "Parameters: $data" : ''}",
    );
    if (headers != null) logger.i(headers);

    final process = _dio.get(
      url,
      data: data,
      options: Options(headers: _buildHeaders(headers)),
    );

    return exceptionThrower?.call(() => process) ??
        handler?.defaultExceptionThrower(() => process) ??
        NetworkErrorsHandler().defaultExceptionThrower(() => process);
  }
}
