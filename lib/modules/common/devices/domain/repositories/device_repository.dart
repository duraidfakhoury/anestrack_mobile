import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';

abstract class DeviceRepository {
  Future<Either<Failure, Unit>> registerDevice({
    required String token,
    required String platform,
    String? deviceInfo,
  });

  Future<Either<Failure, Unit>> unregisterDevice(String token);
}
