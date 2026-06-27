import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/auth/domain/entity/login_response.dart';
import 'package:anestrack_mobile/modules/auth/domain/parameters/login_parameters.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponse>> login(LoginParameters parameters);
  Future<Either<Failure, bool>> logout();
}
