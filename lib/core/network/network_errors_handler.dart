import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/core/network/exeptions/error_message_model.dart';
import 'package:anestrack_mobile/core/network/exeptions/exception.dart';

import 'package:logger/logger.dart';

import 'network_helper.dart';

/// The method of type: [FutureFunction] expresses a waiting condition of type Generic
/// The method of type: [RequestFunction] expresses a waiting condition of type Dio [Response]
typedef FutureFunction<T> = Future<T> Function();
typedef RequestFunction<T> = Future<Response<T>> Function();

/// class [NetworkErrorsHandler] define as Global Exception Handler,
/// [defaultExceptionThrower] handles throw cases of exception according to the application's use cases,
/// [defaultHandleEither] handles possible errors and converting to either form.

class NetworkErrorsHandler {
  Logger logger = Logger();
  // this function to handle APIs exception this make you don't have to call any try catch in your code
  Future<NetworkResponse> defaultExceptionThrower(
    RequestFunction function,
  ) async {
    try {
      /// call Future function and return [AppResponse]
      final response = await function();
      return NetworkResponse.fromDioResponse(response);
    } on DioException catch (e) {
      // check on Dio Exception
      logger.e(e);

      // if back end return an error response and its json format
      // if back end return an error response and its json format
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        logger.e("Server error response: ${e.response!.data}");
        throw ServerException(ErrorMessageModel.fromJson(e.response!));
      }

      if (e.response != null && e.response!.statusCode == 401) {
        throw SessionExpiredException();
      }

      // any anther throws to any anther exception types should be here
      // ...

      // un known Exception
      if (e.response != null) {
        throw UnknownException();
      }

      // no internet Exception
      throw NoInternetException();
    } catch (e) {
      logger.d(e);

      // in json parse error
      if (e is TypeError) {
        throw ParsingException(parsingMessage: e.toString());
      }

      rethrow;
    }
  }

  // this function check possible exceptions and return either (left as Failure , right as Type you generic send)
  Future<Either<Failure, T>> defaultHandleEither<T>(
    FutureOr<T> Function() future,
  ) async {
    try {
      /// first call your [FutureFunction] function
      final result = await future();
      return Right(result);
    } catch (e) {
      /// then catch any errors + check types then return [Left] appropriate [Failure]
      logger.d(
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
}
