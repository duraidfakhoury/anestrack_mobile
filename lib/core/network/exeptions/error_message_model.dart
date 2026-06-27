import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

/// This class [ErrorMessageModel] is defined as the appropriate format for returning error messages from the backend,
/// in an appropriate manner so that the model is received in the interface in a form ready for display.

class ErrorMessageModel extends Equatable {
  final String statusMessage;
  final int? statusCode;
  const ErrorMessageModel({
    required this.statusMessage,
    this.statusCode,
  });

  /// In the existing factory contactor you can assign the path to
  /// the possible [statusMessage] error message returning from the backend.
  /// Ex: statusMessage : response.data['message'] ?? response['error']['message']

  factory ErrorMessageModel.fromJson(Response response) {
    return ErrorMessageModel(
      statusMessage: _getMessage(response),
      statusCode: response.statusCode,
    );
  }

  static String _getMessage(Response response) {
    if (response.data['message'] != null) {
      return response.data['message'];
    }

    if (response.data['error_description'] != null) {
      return response.data['error_description'];
    }

    if (response.data['error'] != null) {
      if (response.data['error'] is Map<String, dynamic> &&
          response.data['error']['message'] != null) {
        return response.data['error']['message'];
      }

      if (response.data['error'] is String) {
        return response.data['error'];
      }
    }

    return "parse Error";
  }

  @override
  List<Object?> get props => [statusMessage, statusCode];
}
