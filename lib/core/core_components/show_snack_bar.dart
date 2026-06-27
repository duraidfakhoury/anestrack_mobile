import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';

void showSnackBar(
  BuildContext context, {
  String? successMessage,
  Failure? failure,
  bool checkFailureType = true,
}) async {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        successMessage ?? failure?.message ?? '',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).primaryColorLight,
        ),
        textAlign: TextAlign.center,
      ),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 5),
    ),
  );

  if (successMessage == null &&
      failure != null &&
      failure is SessionExpiredFailure &&
      checkFailureType) {
    // context.go(HomeRoute.name);
  }
}
