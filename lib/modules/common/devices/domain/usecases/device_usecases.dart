import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/common/devices/domain/repositories/device_repository.dart';

class RegisterDeviceUseCase {
  final DeviceRepository repository;
  RegisterDeviceUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String token,
    required String platform,
    String? deviceInfo,
  }) => repository.registerDevice(
    token: token,
    platform: platform,
    deviceInfo: deviceInfo,
  );
}

class UnregisterDeviceUseCase {
  final DeviceRepository repository;
  UnregisterDeviceUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String token) =>
      repository.unregisterDevice(token);
}
