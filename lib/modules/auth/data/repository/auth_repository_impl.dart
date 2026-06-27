import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/auth/data/data_soure/auth_data_source.dart';
import 'package:anestrack_mobile/modules/auth/domain/entity/login_response.dart';

import 'package:anestrack_mobile/modules/auth/domain/parameters/login_parameters.dart';
import 'package:anestrack_mobile/modules/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource authDataSource;

  AuthRepositoryImpl(this.authDataSource);

  @override
  Future<Either<Failure, LoginResponse>> login(LoginParameters parameters) {
    return AppErrorsHandler().defaultHandleEither(
      () => authDataSource.login(parameters),
    );
  }

  @override
  Future<Either<Failure, bool>> logout() {
    return AppErrorsHandler().defaultHandleEither(
      () => authDataSource.logout(),
    );
  }
}
