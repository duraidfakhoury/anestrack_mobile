import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

part '../enum/log_request_type.dart';

class AppLogger {
  static AppLogger? _instance;
  AppLogger._();
  factory AppLogger() => _instance ??= AppLogger._();

  Logger logger = Logger();

  void logApiCall({
    required LogRequestType type,
    required String url,
    Map<String, dynamic>? headers,
    Object? data,
  }) {
    logger.d(
      "============== ${type.name} METHOD ================= \n URL: ($url) \n ${data != null ? "Parameters: $data" : ''}",
    );
    if (headers != null) logger.i(headers);
  }

  void debugLog(String message) => logger.d(message);
  void debugFLog(String message) => logger.f(message);
  void debugELog(String message) => logger.e(message);
  void debugILog(String message) => logger.i(message);
  void debugTLog(String message) => logger.t(message);
  void debugWLog(String message) => logger.w(message);

  void logException(Exception exception) => logger.e(
    "==================== ${exception.runtimeType} ====================== \n ${exception.toString()} \n ${exception is DioException ? exception.response?.data : ""}",
  );

  void logFailure(Failure failure) => logger.e(
    "==================== ${failure.runtimeType} ====================== \n ${failure.message}",
  );

  void logObject(Object object) => logger.d(
    "==================== ${object.runtimeType} ====================== \n ${object.toString()} \n",
  );

  void printLn(Object? object) {
    if (kDebugMode) {
      print(object);
    }
  }
}
