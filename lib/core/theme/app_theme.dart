import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ----------------- Color Definitions -----------------

  // Light Theme Colors (Figma Design System)
  static const Color primaryLight = AppColors.primaryMainLight; // #704ADD
  static const Color secondaryLight = AppColors.secondaryMainLight; // #01649C
  static const Color backgroundLight = AppColors.bgPrimaryLight; // #FFFFFF
  static const Color surfaceLight = AppColors.bgPrimaryLight; // #FFFFFF
  static const Color errorLight = AppColors.redMainLight; // #D61134
  static const Color onPrimaryLight =
      AppColors.textFilledButtonLight; // #FFFFFF
  static const Color onBackgroundLight = AppColors.textNormalLight; // #253059

  // Dark Theme Colors (Figma Design System)
  static const Color primaryDark = AppColors.primaryMainDark; // #AF94FF
  static const Color secondaryDark = AppColors.secondaryMainDark; // #28B2FF
  static const Color backgroundDark = AppColors.bgPrimaryDark; // #1C1A30
  static const Color surfaceDark = AppColors.bgSecondaryDark; // #0B0B12
  static const Color errorDark = AppColors.redMainDark; // #FF6984
  static const Color onPrimaryDark =
      AppColors.textFilledButtonDark; // #000000 80%
  static const Color onBackgroundDark = AppColors.textNormalDark; // #FFFFFF 90%

  // Gradient Colors
  static const List<Color> primaryGradient = [primaryLight, secondaryLight];
  static const List<Color> secondaryGradient = [
    secondaryLight,
    AppColors.primary100Light, // #916AFF
  ];

  // ----------------- Color Schemes -----------------

  static ColorScheme get _lightColorScheme => const ColorScheme.light(
    primary: primaryLight,
    secondary: secondaryLight,
    error: errorLight,
    onSecondary: AppColors.textFilledButtonLight,
    onSurface: onBackgroundLight,
  );

  static ColorScheme get _darkColorScheme => const ColorScheme.dark(
    primary: primaryDark,
    secondary: secondaryDark,
    surface: surfaceDark,
    error: errorDark,
    onPrimary: onPrimaryDark,
    onSurface: onBackgroundDark,
  );

  // ----------------- Text Themes -----------------

  static TextTheme get _lightTextTheme => _getTextTheme(onBackgroundLight);
  static TextTheme get _darkTextTheme => _getTextTheme(onBackgroundDark);

  /// Funnel Display for display/headline/title, Manrope for body/label.
  static TextTheme _getTextTheme(Color textColor) {
    final display = GoogleFonts.funnelDisplayTextTheme();
    final body = GoogleFonts.manropeTextTheme();

    return TextTheme(
      // Display — Funnel Display
      displayLarge: display.displayLarge!.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displayMedium: display.displayMedium!.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displaySmall: display.displaySmall!.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      // Headline — Funnel Display
      headlineLarge: display.headlineLarge!.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: display.headlineMedium!.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: display.headlineSmall!.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      // Title — Funnel Display
      titleLarge: display.titleLarge!.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleMedium: display.titleMedium!.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: display.titleSmall!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      // Body — Manrope
      bodyLarge: body.bodyLarge!.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: body.bodyMedium!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: body.bodySmall!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      // Label — Manrope
      labelLarge: body.labelLarge!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: body.labelMedium!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: body.labelSmall!.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }

  // ----------------- Main Themes -----------------

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    textTheme: _lightTextTheme,
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLight,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: onBackgroundLight),
      titleTextStyle: _lightTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: const CardThemeData(
      color: surfaceLight,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.panel)),
      ),
    ),
    elevatedButtonTheme: _getElevatedButtonTheme(_lightColorScheme),
    outlinedButtonTheme: _getOutlinedButtonTheme(_lightColorScheme),
    inputDecorationTheme: _getInputDecorationTheme(_lightColorScheme),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: AppColors.grey500Light,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    textTheme: _darkTextTheme,
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: onBackgroundDark),
      titleTextStyle: _darkTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: const CardThemeData(
      color: surfaceDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.panel)),
      ),
    ),
    elevatedButtonTheme: _getElevatedButtonTheme(_darkColorScheme),
    outlinedButtonTheme: _getOutlinedButtonTheme(_darkColorScheme),
    inputDecorationTheme: _getInputDecorationTheme(_darkColorScheme),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryDark,
      unselectedItemColor: AppColors.grey500Dark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  // ----------------- Component Themes -----------------

  static ElevatedButtonThemeData _getElevatedButtonTheme(
    ColorScheme colorScheme,
  ) => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  static OutlinedButtonThemeData _getOutlinedButtonTheme(
    ColorScheme colorScheme,
  ) => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      side: BorderSide(color: colorScheme.primary, width: 2),
      textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  static InputDecorationTheme _getInputDecorationTheme(
    ColorScheme colorScheme,
  ) => InputDecorationTheme(
    filled: true,
    fillColor: colorScheme.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(
        color: colorScheme.onSurface.withValues(alpha: 0.12),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(
        color: colorScheme.onSurface.withValues(alpha: 0.12),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: colorScheme.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: GoogleFonts.manrope(
      color: colorScheme.onSurface.withValues(alpha: 0.5),
    ),
  );

  // ----------------- Decorations & Shadows -----------------

  static BoxDecoration get primaryGradientDecoration => const BoxDecoration(
    gradient: LinearGradient(
      colors: primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static BoxDecoration get secondaryGradientDecoration => const BoxDecoration(
    gradient: LinearGradient(
      colors: secondaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: AppColors.osMainLight.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
