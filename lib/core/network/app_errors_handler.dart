import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/core_components/show_toast.dart';
import 'package:anestrack_mobile/core/network/exeptions/exception.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/core/network/network_errors_handler.dart';
import 'package:anestrack_mobile/core/services/cache_service.dart';

/// The method of type: [FutureFunction] expresses a waiting condition of type Generic
/// The method of type: [RequestFunction] expresses a waiting condition of type Dio [Response]

/// class [AppErrorsHandler] define as Global Exception Handler,
/// [exceptionThrower] handles throw cases of exception according to the application's use cases,
/// [defaultHandleEither] handles possible errors and converting to either form.

class AppErrorsHandler extends NetworkErrorsHandler {
  static AppErrorsHandler? _instance;
  AppErrorsHandler._();
  factory AppErrorsHandler() => _instance ??= AppErrorsHandler._();
  // this function to handle APIs exception this make you don't have to call any try catch in your code

  // this function check possible exceptions and return either (left as Failure , right as Type you generic send)
  @override
  Future<Either<Failure, T>> defaultHandleEither<T>(
    FutureOr<T> Function() future,
  ) async {
    try {
      /// first call your [FutureFunction] function
      final result = await future();
      return Right(result);
    } catch (e) {
      /// then catch any errors + check types then return [Left] appropriate [Failure]
      Logger().e(
        "================== in handleEither Exception ====================== \n ${e.runtimeType} \n ${e.toString()}",
      );

      if (e is ServerException) {
        return Left(
          ServerFailure(
            e.errorMessageModel.statusMessage,
            statusCode: e.errorMessageModel.statusCode,
          ),
        );
      }
      if (e is NoInternetException) {
        return Left(NoInternetFailure());
      }
      if (e is UnknownException) {
        return Left(UnknownFailure());
      }
      if (e is ForceUpdateException) {
        return Left(ForceUpdateFailure());
      }
      if (e is ApplicationUnderMaintenanceException) {
        return Left(AppUnderMaintenanceFailure());
      }
      if (e is SessionExpiredException) {
        logout();
        return Left(SessionExpiredFailure());
      }
      if (e is ParsingException || e is TypeError) {
        return Left(
          ParsingFailure(
            parsingMessage: e is ParsingException
                ? e.parsingMessage
                : e.toString(),
          ),
        );
      }
      return Left(Failure(e.toString()));
    }
  }

  void logout() async {
    Logger().d("Logout - Session");
    await CacheService().removeToken();
    await CacheService().removeRefreshToken();
    showToast('Seesion Expired , relogin to your account');
  }
}
