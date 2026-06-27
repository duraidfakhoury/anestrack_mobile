import 'package:flutter/widgets.dart';

class ScreenSizeService {
  static T? onScreenWidth<T>(BuildContext context,
      {T Function()? onMobile,
      T Function()? onTablet,
      T Function()? onDesktop,
      T Function()? onMobileAndTablet,
      T Function()? onMobileAndDesktop,
      T Function()? onTabletAndDesktop}) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return onMobileAndTablet?.call() ??
          onMobileAndDesktop?.call() ??
          onMobile?.call();
    } else if (screenWidth >= 600 && screenWidth <= 1024) {
      return onMobileAndTablet?.call() ??
          onTabletAndDesktop?.call() ??
          onTablet?.call();
    } else {
      return onMobileAndDesktop?.call() ??
          onTabletAndDesktop?.call() ??
          onDesktop?.call();
    }
  }

  static bool isDesktop(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return (screenWidth >= 1024);
  }

  static bool isTablet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return (screenWidth >= 600 && screenWidth < 1024);
  }

  static bool isMobile(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return (screenWidth < 600);
  }
}
