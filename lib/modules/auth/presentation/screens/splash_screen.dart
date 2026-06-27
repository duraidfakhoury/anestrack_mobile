import 'dart:convert';

import 'package:anestrack_mobile/core/enum/user_type.dart';
import 'package:anestrack_mobile/core/services/cache_service.dart';
import 'package:anestrack_mobile/modules/auth/data/models/user_model.dart';
import 'package:anestrack_mobile/modules/auth/presentation/routes/login_route.dart';
import 'package:anestrack_mobile/modules/supervisor/home/presentation/routes/supervisor_home_route.dart';
import 'package:anestrack_mobile/modules/student/home/presentation/routes/student_home_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  /// This screen is fully Responsive
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _afterSplash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png", scale: 0.9.h / 1),
              const SizedBox(height: 20),
              Text(
                "anestrack mobile",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 6,
                ),
              ),

              const SizedBox(height: 30),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _afterSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final cache = CacheService();
    if (!cache.hasToken) {
      context.go(LoginRoute.name);
      return;
    }

    var role = cache.userRole;
    if (role.isEmpty) {
      role = _userRoleFromCache(cache);
      if (role.isNotEmpty) {
        await cache.setUserRole(role);
      }
    }

    if (!mounted) return;

    final userType = _resolveUserType(role);
    if (userType == null) {
      context.go(LoginRoute.name);
      return;
    }

    context.go(_routeForUserType(userType));
  }

  String _userRoleFromCache(CacheService cache) {
    if (!cache.hasUser) return '';
    final rawUser = cache.user;
    if (rawUser.isEmpty) return '';
    final decoded = jsonDecode(rawUser);
    if (decoded is! Map<String, dynamic>) return '';
    return UserModel.fromJson(decoded).userType;
  }

  UserType? _resolveUserType(String rawType) {
    final normalized = rawType.trim().toLowerCase();
    if (normalized == 'student') {
      return UserType.student;
    }
    if (normalized == 'supervisor' || normalized == 'superviser') {
      return UserType.supervisor;
    }
    return null;
  }

  String _routeForUserType(UserType userType) {
    switch (userType) {
      case UserType.student:
        return StudentHomeRoute.name;
      case UserType.supervisor:
        return SupervisorHomeRoute.name;
    }
  }
}
