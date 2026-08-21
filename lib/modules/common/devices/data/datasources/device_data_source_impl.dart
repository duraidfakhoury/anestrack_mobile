import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/common/devices/data/datasources/device_data_source.dart';

class DeviceDataSourceImpl extends DeviceDataSource {
  final Logger _logger = Logger();

  @override
  Future<void> registerDevice({
    required String token,
    required String platform,
    String? deviceInfo,
  }) async {
    try {
      final response = await NetworkHelper().post(
        ApisUrls().registerDevice,
        data: {
          'token': token,
          'platform': platform,
          if (deviceInfo != null) 'deviceInfo': deviceInfo,
        },
      );
      _logger.i('Device registered: ${response.data}');
    } catch (e) {
      _logger.e('Failed to register device: $e');
      rethrow;
    }
  }

  @override
  Future<void> unregisterDevice(String token) async {
    try {
      await NetworkHelper().post(
        ApisUrls().unregisterDevice,
        data: {'token': token},
      );
    } catch (e) {
      _logger.e('Failed to unregister device: $e');
      rethrow;
    }
  }
}
