import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/common/profile/domain/entities/current_user.dart';

abstract class ProfileRepository {
  Future<Either<Failure, CurrentUser>> getCurrentUser();
}
