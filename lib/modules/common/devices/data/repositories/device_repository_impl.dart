import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/common/devices/data/datasources/device_data_source.dart';
import 'package:anestrack_mobile/modules/common/devices/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl extends DeviceRepository {
  final DeviceDataSource dataSource;

  DeviceRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Unit>> registerDevice({
    required String token,
    required String platform,
    String? deviceInfo,
  }) {
    return AppErrorsHandler().defaultHandleEither(() async {
      await dataSource.registerDevice(
        token: token,
        platform: platform,
        deviceInfo: deviceInfo,
      );
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> unregisterDevice(String token) {
    return AppErrorsHandler().defaultHandleEither(() async {
      await dataSource.unregisterDevice(token);
      return unit;
    });
  }
}
