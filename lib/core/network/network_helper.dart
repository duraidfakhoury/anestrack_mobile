import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/network/base_headers.dart';
import 'package:anestrack_mobile/core/network/network_errors_handler.dart';
import 'dio_network_helper.dart';

part 'network_response.dart';

abstract class NetworkHelper {
  factory NetworkHelper() => DioNetworkHelper();
  NetworkHelper.create();

  Future<NetworkResponse> get(
    String url, {
    Map<String, dynamic>? headers,
    Object? data,
    Future<NetworkResponse> Function(RequestFunction function)?
    exceptionThrower,
  });

  late BaseHeaders headers;
  NetworkErrorsHandler? handler;

  void init({required BaseHeaders headers, NetworkErrorsHandler? handler}) {
    this.headers = headers;
    this.handler = handler;
  }

  Future<NetworkResponse> post(
    String url, {
    Map<String, dynamic>? headers,
    Object? data,
    Future<NetworkResponse> Function(RequestFunction function)?
    exceptionThrower,
  });

  Future<NetworkResponse> put(
    String url, {
    Map<String, dynamic>? headers,
    Object? data,
    Future<NetworkResponse> Function(RequestFunction function)?
    exceptionThrower,
  });

  Future<NetworkResponse> delete(
    String url, {
    Map<String, dynamic>? headers,
    Object? data,
    Future<NetworkResponse> Function(RequestFunction function)?
    exceptionThrower,
  });

  Future<NetworkResponse> query(
    String url,
    String query,
    Map<String, dynamic>? headers,
    Future<NetworkResponse> Function(RequestFunction function)?
    exceptionThrower,
  ) => post(
    url,
    data: {'query': query},
    headers: headers,
    exceptionThrower: exceptionThrower,
  );
}
