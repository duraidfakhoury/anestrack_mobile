part of '../utils/app_logger.dart';

enum LogRequestType {
  post("POST"),
  delete("DELETE"),
  put("PUT"),
  get("GET");

  final String name;
  const LogRequestType(this.name);
}
