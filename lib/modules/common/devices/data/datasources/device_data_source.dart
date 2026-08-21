abstract class DeviceDataSource {
  Future<void> registerDevice({
    required String token,
    required String platform,
    String? deviceInfo,
  });

  Future<void> unregisterDevice(String token);
}
