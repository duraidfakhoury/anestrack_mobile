part of 'network_helper.dart';

class NetworkResponse {
  final dynamic data;
  final int statusCode;
  final Map<String, String>? headers;

  NetworkResponse({this.data, required this.statusCode, this.headers});
  Logger logger = Logger();
  factory NetworkResponse.fromDioResponse(Response response) {
    Logger().d(response.data);
    return NetworkResponse(
      statusCode: response.statusCode ?? 500,
      headers:
          response.headers.map.map((key, value) => MapEntry(key, value.first)),
      data: response.data,
    );
  }

  List<T> toList<T>(T Function(Map<String, dynamic> json) fromJson,
      {String? index}) {
    return ((index != null ? data[index] : data) as List)
        .map((e) => fromJson(e))
        .toList();
  }
}
