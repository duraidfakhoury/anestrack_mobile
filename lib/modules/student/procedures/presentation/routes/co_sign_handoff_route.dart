import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/screens/co_sign_handoff_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoSignHandoffRoute {
  static const String name = '/student-home/co-sign';

  static GoRoute route = GoRoute(
    path: name,
    builder: (context, state) {
      final result = state.extra as CreateProcedureResult?;
      if (result == null) {
        // Direct navigation without a result — nothing to hand off.
        return const Scaffold(
          body: Center(child: Text('لا يوجد رمز توقيع')),
        );
      }
      return CoSignHandoffScreen(result: result);
    },
  );
}
