import 'dart:convert';

import 'package:anestrack_mobile/core/utils/app_logger.dart';
import 'package:flutter/services.dart';

class AppConfig {
  static AppConfig? _instance;
  AppConfig._();
  factory AppConfig() => _instance ??= AppConfig._();

  late String baseUrl;
  late String xParseApplicationId;
  late String xParseRestApiKey;
  Future<void> initVariables() async {
    try {
      final String contents = await rootBundle.loadString('assets/config.json');
      final Map<String, dynamic> data = json.decode(contents);
      final String baseUrl = data['baseUrl'];
      final String xParseApplicationId = data['X-Parse-Application-Id'];
      final String xParseRestApiKey = data['X-Parse-REST-API-Key'];

      this.baseUrl = baseUrl;
      this.xParseApplicationId = xParseApplicationId;
      this.xParseRestApiKey = xParseRestApiKey;
      AppLogger().debugFLog("Base URL: $baseUrl");
    } catch (e) {
      AppLogger().debugFLog("Error in base url init: $e");
      setDefaultValues();
    }
  }

  void setDefaultValues() {
    baseUrl = '';
    xParseApplicationId = '';
    xParseRestApiKey = '';
  }
}
