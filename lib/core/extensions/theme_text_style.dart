import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/constants/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

extension ThemeTextStyle on ThemeData {
  TextStyle get futuraSplashTitleTextStyle => TextStyle(
    color: AppColors.white,
    fontSize: 17.sp,
    letterSpacing: 3,
    fontFamily: AppFonts.futura,
  );

  TextStyle get redUnderLineHeadLineTextStyle => textTheme.bodyLarge!.copyWith(
    color: AppColors.red,
    decoration: TextDecoration.underline,
  );

  TextStyle get greenUnderLineHeadLineTextStyle => textTheme.headlineLarge!
      .copyWith(color: AppColors.green, decoration: TextDecoration.underline);

  TextStyle get appTextFieldSmallTextStyle {
    return TextStyle(color: primaryColor);
  }

  TextStyle get appTextFieldMediumTextStyle {
    return TextStyle(color: primaryColor, fontSize: 18);
  }
}
