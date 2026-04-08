import 'package:flutter/material.dart';

/// Application theme configuration for the Poker Dice game.
///
/// Defines color scheme, typography, and spacing for a consistent UI
/// with blue gradient background and yellow/orange accents.
class AppTheme {
  AppTheme._();

  /// Primary blue gradient colors
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1565C0);

  /// Accent colors
  static const Color accentYellow = Color(0xFFFFB74D);
  static const Color accentOrange = Color(0xFFFF9800);

  /// Score box colors
  static const Color scoreBoxLightBlue = Color(0xFF4FC3F7);
  static const Color scoreTextWhite = Color(0xFFFFFFFF);

  /// Background and surface colors
  static const Color backgroundGradientStart = Color(0xFF1E88E5);
  static const Color backgroundGradientEnd = Color(0xFF1565C0);
  static const Color surfaceDark = Color(0xFF0D47A1);
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Die colors
  static const Color dieFace = Color(0xFFFFFFFF);
  static const Color dieDot = Color(0xFF000000);
  static const Color dieBorder = Color(0xFFFF9800);

  /// Text colors
  static const Color textPrimary = Color(0xFF0D47A1);
  static const Color textSecondary = Color(0xFF424242);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Creates the light theme data.
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryLight,
        brightness: Brightness.light,
        primary: primaryLight,
        onPrimary: textOnPrimary,
        secondary: accentYellow,
        onSecondary: textPrimary,
        surface: scoreBoxLightBlue,
        onSurface: scoreTextWhite,
        error: Colors.redAccent,
        onError: textOnPrimary,
      ),
      scaffoldBackgroundColor: backgroundGradientStart,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textOnPrimary),
        titleTextStyle: TextStyle(
          color: textOnPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textOnPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textOnPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textOnPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textOnPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textOnPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textOnPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textOnPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceDark,
          foregroundColor: textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentOrange,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  /// Creates the dark theme data.
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryLight,
        brightness: Brightness.dark,
        primary: primaryLight,
        onPrimary: textOnPrimary,
        secondary: accentYellow,
        onSecondary: textPrimary,
        surface: scoreBoxLightBlue,
        onSurface: scoreTextWhite,
        error: Colors.redAccent,
        onError: textOnPrimary,
      ),
      scaffoldBackgroundColor: backgroundGradientEnd,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textOnPrimary),
        titleTextStyle: TextStyle(
          color: textOnPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textOnPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textOnPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textOnPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textOnPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textOnPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textOnPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textOnPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textOnPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textOnPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceDark,
          foregroundColor: textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentOrange,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  /// Returns the theme based on the system brightness.
  static ThemeData getThemeForSystem() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? darkTheme() : lightTheme();
  }
}

/// Spacing constants for consistent UI layout.
class AppSpacing {
  AppSpacing._();

  /// Extra small spacing (2px)
  static const double xs = 2.0;

  /// Small spacing (4px)
  static const double sm = 4.0;

  /// Medium spacing (8px)
  static const double md = 8.0;

  /// Large spacing (12px)
  static const double lg = 12.0;

  /// Extra large spacing (16px)
  static const double xl = 16.0;

  /// Double extra large spacing (24px)
  static const double xxl = 24.0;

  /// Triple extra large spacing (32px)
  static const double xxxl = 32.0;
}

/// Typography constants for consistent text styling.
class AppTypography {
  AppTypography._();

  /// Small font size (12px)
  static const double small = 12.0;

  /// Medium font size (14px)
  static const double medium = 14.0;

  /// Large font size (16px)
  static const double large = 16.0;

  /// Extra large font size (20px)
  static const double extraLarge = 20.0;

  /// Title font size (24px)
  static const double title = 24.0;

  /// Display font size (32px)
  static const double display = 32.0;
}
