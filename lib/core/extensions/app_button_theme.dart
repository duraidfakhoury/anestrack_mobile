import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

extension AppButtonTheme on ThemeData {
  ButtonStyle redAppButtonStyle({double? radius, required bool isActive}) {
    return ButtonStyle(
      alignment: Alignment.center,
      backgroundColor: WidgetStatePropertyAll<Color?>(
        isActive
            ? AppColors.red
            : AppTheme().isLightByBrightness(brightness)
            ? AppColors.borderGray
            : AppColors.grey,
      ),
      overlayColor: WidgetStatePropertyAll(
        primaryColorLight.withValues(alpha: 0.1),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 9),
        ),
      ),
    );
  }

  ButtonStyle normalAppButtonStyle({double? radius, required bool isActive}) {
    return ButtonStyle(
      alignment: Alignment.center,
      backgroundColor: WidgetStatePropertyAll<Color?>(
        isActive
            ? AppColors.primaryBlue
            : AppTheme().isLightByBrightness(brightness)
            ? AppColors.borderColor
            : AppColors.grey,
      ),
      overlayColor: WidgetStatePropertyAll(
        AppColors.primaryBlueDark.withValues(alpha: 0.1),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 9),
        ),
      ),
    );
  }

  ButtonStyle unFilledAppButtonStyle({double? radius}) {
    return ButtonStyle(
      alignment: Alignment.center,
      overlayColor: WidgetStatePropertyAll(
        primaryColorDark.withValues(alpha: 0.05),
      ),
      backgroundColor: WidgetStatePropertyAll<Color?>(primaryColorLight),
      elevation: const WidgetStatePropertyAll<double?>(1),
      foregroundColor: WidgetStatePropertyAll(primaryColorLight),
      surfaceTintColor: WidgetStatePropertyAll(primaryColorLight),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 9),
          side: BorderSide(color: primaryColorDark, width: 1),
        ),
      ),
    );
  }

  ButtonStyle redBorderAppButtonStyle({double? radius}) => ButtonStyle(
    elevation: const WidgetStatePropertyAll(0),
    alignment: Alignment.center,
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.w),
    ),
    backgroundColor: WidgetStatePropertyAll(
      primaryColorLight.withValues(alpha: 0.4),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius ?? 9)),
    ),
    side: const WidgetStatePropertyAll(BorderSide(color: AppColors.red)),
  );

  ButtonStyle greyAppButtonStyle({double? radius}) {
    return ButtonStyle(
      alignment: Alignment.center,
      backgroundColor: const WidgetStatePropertyAll<Color?>(AppColors.darkGray),
      overlayColor: WidgetStatePropertyAll(
        AppColors.black.withValues(alpha: 0.1),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 9),
        ),
      ),
    );
  }
}
