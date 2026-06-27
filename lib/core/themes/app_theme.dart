import 'package:anestrack_mobile/core/enum/app_font_weight.dart';
import 'package:anestrack_mobile/core/enum/app_theme_mode.dart';
import 'package:anestrack_mobile/core/services/cache_service.dart';
import 'package:anestrack_mobile/core/services/screen_size_service.dart';
import 'package:anestrack_mobile/core/themes/bloc/theme_bloc.dart';
import 'package:anestrack_mobile/core/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

/// This class [AppTheme] is defined to contain two basic variables that represent the application's theme,
///  where [darkTheme] represents the dark theme, [lightTheme] represents the basic theme.
///

class AppTheme {
  static AppTheme? _instance;
  AppTheme._();
  factory AppTheme() => _instance ??= AppTheme._();

  ThemeMode themeMode(BuildContext context) =>
      isDark(context) ? ThemeMode.dark : ThemeMode.light;

  ///////////////////// lightTheme /////////////////////////
  ThemeData lightTheme(BuildContext context) => ThemeData.light().copyWith(
    brightness: Brightness.light,

    primaryColor: AppColors.primaryBlue,
    primaryColorDark: AppColors.primaryBlueDark,
    primaryColorLight: AppColors.primaryBlueLight,
    textTheme: TextTheme(
      // Headline
      headlineLarge: textStyle(
        context,
        AppFontWeight.medium,
        AppColors.textPrimary,
        18,
      ),
      headlineMedium: textStyle(
        context,
        AppFontWeight.medium,
        AppColors.textPrimary,
        17,
      ),
      headlineSmall: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.textPrimary,
        16,
      ),

      // Title
      titleLarge: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.textPrimary,
        21,
      ),
      titleMedium: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.textPrimary,
        18,
      ),
      titleSmall: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.textPrimary,
        16,
      ),

      // body
      bodyLarge: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.textPrimary,
        16,
      ),
      bodyMedium: textStyle(
        context,
        AppFontWeight.light,
        AppColors.textPrimary,
        16,
      ),
      bodySmall: textStyle(
        context,
        AppFontWeight.light,
        AppColors.textSecondary,
        14.3,
      ),

      // display
      displayLarge: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        18,
      ),
      displayMedium: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        16,
      ),
      displaySmall: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        15,
      ),

      // label
      labelLarge: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.textPrimary,
        18,
      ),
      labelMedium: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.textPrimary,
        16,
      ),
      labelSmall: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.textPrimary,
        15,
      ),
    ),

    // Light App Bar Theme
    appBarTheme: AppBarTheme(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.borderColor),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      backgroundColor: AppColors.cardBackground,
      elevation: 8,
      iconTheme: IconThemeData(
        color: AppColors.textPrimary,
        size: iconSize(context, size: 18),
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.textPrimary,
        size: iconSize(context, size: 18),
      ),
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: AppColors.cardBackground,
      toolbarTextStyle: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.textPrimary,
        16,
      ),
      titleTextStyle: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.textPrimary,
        17,
      ),
    ),

    // Light Scaffold Color
    scaffoldBackgroundColor: AppColors.neutralBackground,

    // Light Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      errorMaxLines: 2,
      iconColor: AppColors.textSecondary,
      hintStyle: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.textSecondary,
        15,
      ),
      suffixIconColor: AppColors.textSecondary,
      prefixIconColor: AppColors.textSecondary,
      filled: true,
      fillColor: AppColors.cardBackground,
      border: outlineInputBorder(
        const BorderSide(color: AppColors.borderColor, width: 1),
      ),
      enabledBorder: outlineInputBorder(
        const BorderSide(color: AppColors.borderColor, width: 1),
      ),
      focusedErrorBorder: outlineInputBorder(
        const BorderSide(color: AppColors.red, width: 1.8),
      ),
      errorBorder: outlineInputBorder(
        const BorderSide(color: AppColors.red, width: 1),
      ),
      focusedBorder: outlineInputBorder(
        const BorderSide(color: AppColors.primaryBlue, width: 1.8),
      ),
      labelStyle: textStyle(
        context,
        AppFontWeight.light,
        AppColors.textSecondary,
        13,
      ),
      errorStyle: textStyle(context, AppFontWeight.light, AppColors.red, 15),
      counterStyle: textStyle(
        context,
        AppFontWeight.light,
        AppColors.textSecondary,
        15,
      ),
      isDense: true,
      helperStyle: textStyle(
        context,
        AppFontWeight.light,
        AppColors.textSecondary,
        15,
      ),
      suffixStyle: textStyle(
        context,
        AppFontWeight.light,
        AppColors.textSecondary,
        15,
      ),
      prefixStyle: textStyle(
        context,
        AppFontWeight.light,
        AppColors.textSecondary,
        15,
      ),
    ),

    // Light snackBar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.blackAccent.withValues(alpha: 0.8),
      contentTextStyle: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        15,
      ),
      actionTextColor: AppColors.white,
    ),

    // Light actionIcon Theme
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) => const Icon(
        Icons.arrow_back_ios_rounded,
        color: AppColors.textPrimary,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.light,
      primary: AppColors.primaryBlue,
      onPrimary: AppColors.white,
    ),
    canvasColor: AppColors.neutralBackground,

    // Light floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryBlue,
      elevation: 2,
      iconSize: iconSize(context, size: 25),
      foregroundColor: AppColors.white,
    ),

    // Light Icon Theme
    iconTheme: IconThemeData(
      color: AppColors.textPrimary,
      size: iconSize(context, size: 18),
    ),

    // Light  bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardBackground,
      elevation: 2,
      unselectedLabelStyle: textStyle(
        context,
        AppFontWeight.light,
        AppColors.textSecondary,
        13,
      ),
      selectedLabelStyle: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.textPrimary,
        13,
      ),
      unselectedIconTheme: IconThemeData(
        color: AppColors.textSecondary,
        size: iconSize(context, size: 20),
      ),
      unselectedItemColor: AppColors.textSecondary,
      selectedIconTheme: IconThemeData(
        color: AppColors.primaryBlue,
        size: iconSize(context, size: 23),
      ),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: AppColors.primaryBlue,
      type: BottomNavigationBarType.shifting,
    ),
  );

  ///////////////////// Dark Theme /////////////////////////
  ThemeData darkTheme(BuildContext context) => ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    primaryColor: AppColors.white,
    primaryColorDark: AppColors.white,
    primaryColorLight: AppColors.black,
    textTheme: TextTheme(
      // Headline
      headlineLarge: textStyle(
        context,
        AppFontWeight.medium,
        AppColors.white,
        18,
      ),
      headlineMedium: textStyle(
        context,
        AppFontWeight.medium,
        AppColors.white,
        17,
      ),
      headlineSmall: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        16,
      ),

      // Title
      titleLarge: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        21,
      ),
      titleMedium: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        18,
      ),
      titleSmall: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        16,
      ),

      // body
      bodyLarge: textStyle(context, AppFontWeight.regular, AppColors.white, 16),
      bodyMedium: textStyle(context, AppFontWeight.light, AppColors.white, 16),
      bodySmall: textStyle(context, AppFontWeight.light, AppColors.white, 14.3),

      // display
      displayLarge: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.black,
        18,
      ),
      displayMedium: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.black,
        16,
      ),
      displaySmall: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.black,
        15,
      ),

      // label
      labelLarge: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        18,
      ),
      labelMedium: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        16,
      ),
      labelSmall: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        15,
      ),
    ),

    // Dark App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      elevation: 8,
      iconTheme: IconThemeData(
        color: AppColors.white,
        size: iconSize(context, size: 18),
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.white,
        size: iconSize(context, size: 18),
      ),
      foregroundColor: AppColors.white,
      surfaceTintColor: AppColors.black,
      toolbarTextStyle: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        16,
      ),
      titleTextStyle: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        17,
      ),
    ),

    // Dark Scaffold Color
    scaffoldBackgroundColor: AppColors.black,

    // Dark Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      errorMaxLines: 2,
      iconColor: AppColors.white,
      hintStyle: textStyle(context, AppFontWeight.regular, AppColors.white, 15),
      suffixIconColor: AppColors.white,
      prefixIconColor: AppColors.white,
      filled: true,
      fillColor: AppColors.black,
      border: outlineInputBorder(
        const BorderSide(color: AppColors.white, width: 1),
      ),
      enabledBorder: outlineInputBorder(
        const BorderSide(color: AppColors.white, width: 1),
      ),
      focusedErrorBorder: outlineInputBorder(
        const BorderSide(color: AppColors.redAccent, width: 1.8),
      ),
      errorBorder: outlineInputBorder(
        const BorderSide(color: AppColors.redAccent, width: 1),
      ),
      focusedBorder: outlineInputBorder(
        const BorderSide(color: AppColors.white, width: 1.8),
      ),
      labelStyle: textStyle(context, AppFontWeight.light, AppColors.white, 13),
      errorStyle: textStyle(
        context,
        AppFontWeight.light,
        AppColors.redAccent,
        15,
      ),
      counterStyle: textStyle(
        context,
        AppFontWeight.light,
        AppColors.white,
        15,
      ),
      isDense: true,
      helperStyle: textStyle(context, AppFontWeight.light, AppColors.white, 15),
      suffixStyle: textStyle(context, AppFontWeight.light, AppColors.white, 15),
      prefixStyle: textStyle(context, AppFontWeight.light, AppColors.white, 15),
    ),

    // Dark snackBar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.white.withValues(alpha: 0.8),
      contentTextStyle: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        15,
      ),
      actionTextColor: AppColors.black,
    ),

    // Dark actionIcon Theme
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) =>
          const Icon(Icons.arrow_back_ios_rounded, color: AppColors.white),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: AppColors.darkMaterialColor,
      brightness: Brightness.dark,
    ),
    canvasColor: AppColors.white,

    // Dark floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.white,
      elevation: 2,
      iconSize: iconSize(context, size: 25),
      foregroundColor: AppColors.black,
    ),

    // Dark Icon Theme
    iconTheme: IconThemeData(
      color: AppColors.white,
      size: iconSize(context, size: 18),
    ),

    // Dark  bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.blackAccent,
      elevation: 2,
      unselectedLabelStyle: textStyle(
        context,
        AppFontWeight.light,
        AppColors.darkGray,
        16,
      ),
      selectedLabelStyle: textStyle(
        context,
        AppFontWeight.regular,
        AppColors.white,
        16,
      ),
      unselectedIconTheme: IconThemeData(
        color: AppColors.greyAccent,
        size: iconSize(context, size: 20),
      ),
      unselectedItemColor: AppColors.darkGray,
      selectedIconTheme: IconThemeData(
        color: AppColors.white,
        size: iconSize(context, size: 23),
      ),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: AppColors.black,
      type: BottomNavigationBarType.shifting,
    ),
  );

  double iconSize(BuildContext context, {required num size}) {
    return ScreenSizeService.onScreenWidth(
          context,
          onMobile: () => size.sp,
          onDesktop: () => size.toDouble(),
          onTablet: () => (size - 2).sp,
        ) ??
        (size).sp;
  }

  void refreshTheme(BuildContext context) {
    context.read<ThemeBloc>().add(
      CacheService().theme ? SetDarkThemeEvent() : SetLightThemeEvent(),
    );
  }

  void changeTheme(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? context.read<ThemeBloc>().add(SetDarkThemeEvent())
      : context.read<ThemeBloc>().add(SetLightThemeEvent());

  void setDarkMode(BuildContext context) =>
      context.read<ThemeBloc>().add(SetDarkThemeEvent());

  void setLightMode(BuildContext context) =>
      context.read<ThemeBloc>().add(SetLightThemeEvent());

  bool isLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light;

  AppThemeMode currentAppTheme(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? AppThemeMode.light
      : AppThemeMode.dark;

  bool isLightByBrightness(Brightness brightness) =>
      brightness == Brightness.light;

  bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  bool isDarkByBrightness(Brightness brightness) =>
      brightness == Brightness.dark;

  TextStyle textStyle(
    BuildContext context,
    AppFontWeight appFontWeight,
    Color? color,
    double size, {
    String? family,
  }) => TextStyle(
    fontFamily:
        family ??
        (AppLocale().isEnglish(context) ? AppFonts.kanit : AppFonts.almarai),
    color: color,
    fontWeight: _getFontWeight(appFontWeight),
    fontSize:
        ScreenSizeService.onScreenWidth(
          context,
          onMobile: () => size.sp,
          onDesktop: () => size - 2,
          onTablet: () => (size - 2).sp,
        ) ??
        (size).sp,
    height: AppLocale().isArabic(context) ? 1.5 : null,
  );

  FontWeight _getFontWeight(AppFontWeight appFontWeight) {
    switch (appFontWeight) {
      case AppFontWeight.bold:
        return FontWeight.bold;
      case AppFontWeight.light:
        return FontWeight.w300;
      case AppFontWeight.medium:
        return FontWeight.w500;
      case AppFontWeight.regular:
        return FontWeight.normal;
    }
  }

  OutlineInputBorder outlineInputBorder(
    BorderSide borderSide, {
    BorderRadius? borderRadius,
  }) => OutlineInputBorder(
    borderRadius: borderRadius ?? BorderRadius.circular(9),
    borderSide: borderSide,
  );
}
