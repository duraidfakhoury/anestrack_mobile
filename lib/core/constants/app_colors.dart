import 'package:flutter/material.dart';

/// Define this class for all colors that can be used in the application
/// You can define [Color] in the following way:
///
/// static const Color colorName = Color(colorHex);
///
///
/// You can also define [MaterialColor] in the same class in the following way:
///
/// static const MaterialColor materialColor = MaterialColor(
///     colorHex,
///     \<int, Color>{
///       50: Color(colorHex50),
///       100: Color(colorHex100),
///       200: Color(colorHex200),
///       300: Color(colorHex300),
///       400: Color(colorHex400),
///       500: Color(colorHex500),
///       600: Color(colorHex600),
///       700: Color(colorHex700),
///       800: Color(colorHex800),
///       900: Color(colorHex900),
///     },
///   );

class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color semiBlack = Color(0xFF4A4A4A);
  static const Color blackAccent = Color(0xFF333333);

  static const Color redAccent = Color.fromARGB(255, 255, 52, 72);
  static const Color red = Color(0XFFDE0017);
  static const Color grey = Color(0xFFD1D1D1);

  static const Color greyAccent = Color(0xFFF4F4F4);
  static const Color gold = Color.fromARGB(255, 212, 166, 97);
  static const Color textGrey = Color(0xFFA89E9E);
  static const Color darkGray = Color.fromARGB(255, 183, 183, 183);
  static const Color borderGray = Color(0xFF707070);
  static const Color cardGray = Color(0xFFD1D1D1);
  static const Color greenAccent = Color(0xFFD9ECD9);

  static const Color mold = Color(0xFFD8E6D8);
  static const Color green = Color(0xFF288328);

  static const Color orange = Colors.orange;
  static const Color blue = Colors.blue;

  static const Color white = Color(0xFFFFFFFF);

  // Primary (Main Brand Color)
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color primaryBlueDark = Color(0xFF004FCC);
  static const Color primaryBlueLight = Color(0xFFE6F0FF);

  // Secondary (Supporting Color)
  static const Color secondaryOrange = Color(0xFFFFAA00);
  static const Color secondaryOrangeDark = Color(0xFFFF6B00);
  static const Color secondaryOrangeLight = Color(0xFFFFF5E6);

  // Tertiary (UI Neutral Colors)
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color borderColor = Color(0xFFE5E5E5);
  static const Color neutralBackground = Color(0xFFF7F7F7);
  static const Color cardBackground = Color(0xFFFFFFFF);

  static const Color shadowBlack = Color(0x29000000);
  static const Color transparent = Colors.transparent;

  // Brand palettes
  static const Color studentPrimary = Color(0xFF0D9488);
  static const Color studentPrimaryDark = Color(0xFF0E7490);
  static const Color studentPrimaryLight = Color(0xFFCCFBF1);
  static const Color supervisorPrimary = Color(0xFF4338CA);

  // Tailwind-inspired neutrals
  static const Color slate900 = Color(0xFF1F2937);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF374151);
  static const Color slate600Dark = Color(0xFF4B5563);
  static const Color slate600 = Color(0xFF6B7280);
  static const Color slate500 = Color(0xFF9CA3AF);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);

  // Accent palettes
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color cyan600 = Color(0xFF0891B2);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo800 = Color(0xFF3730A3);
  static const Color indigo900 = Color(0xFF312E81);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red600 = Color(0xFFDC2626);
  static const Color purple100 = Color(0xFFEDE9FE);
  static const Color purple600 = Color(0xFF7C3AED);
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);

  // Shadows
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);

  static MaterialColor _createMaterialColor(Color color) {
    Map<int, Color> swatch = {
      50: color.withValues(alpha: 0.05),
      100: color.withValues(alpha: 0.1),
      200: color.withValues(alpha: 0.2),
      300: color.withValues(alpha: 0.3),
      400: color.withValues(alpha: 0.4),
      500: color.withValues(alpha: 0.5),
      600: color.withValues(alpha: 0.6),
      700: color.withValues(alpha: 0.7),
      800: color.withValues(alpha: 0.8),
      900: color.withValues(alpha: 0.9),
    };
    return MaterialColor(color.toARGB32(), swatch);
  }

  static final MaterialColor lightMaterialColor = _createMaterialColor(black);
  static final MaterialColor darkMaterialColor = _createMaterialColor(white);
}
