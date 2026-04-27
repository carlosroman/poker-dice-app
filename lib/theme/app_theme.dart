import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration for Poker Dice game.
///
/// Provides light and dark theme variants with a cohesive color scheme
/// designed for a premium gaming experience.
class AppTheme {
  /// Color constants for the Poker Dice game theme.

  /// Primary color: Deep blue-purple for game branding
  static const Color PRIMARY_COLOR = Color(0xFF5C6BC0);

  /// Secondary/Accent color: Orange for held dice and highlights
  static const Color ACCENT_COLOR = Color(0xFFFF9800);

  /// Error color for invalid states
  static const Color ERROR_COLOR = Color(0xFFF44336);

  /// Success color for scoring feedback
  static const Color SUCCESS_COLOR = Color(0xFF4CAF50);

  /// Warning color for important notifications
  static const Color WARNING_COLOR = Color(0xFFFFC107);

  /// Light mode background color
  static const Color BACKGROUND_LIGHT = Color(0xFFFAFAFA);

  /// Dark mode background color
  static const Color BACKGROUND_DARK = Color(0xFF121212);

  /// Light mode surface color for cards and panels
  static const Color SURFACE_LIGHT = Color(0xFFFFFFFF);

  /// Dark mode surface color for cards and panels
  static const Color SURFACE_DARK = Color(0xFF1E1E1E);

  /// Light mode primary text color
  static const Color TEXT_PRIMARY_LIGHT = Color(0xFF212121);

  /// Dark mode primary text color
  static const Color TEXT_PRIMARY_DARK = Color(0xFFFFFFFF);

  /// Light mode secondary text color
  static const Color TEXT_SECONDARY_LIGHT = Color(0xFF757575);

  /// Dark mode secondary text color
  static const Color TEXT_SECONDARY_DARK = Color(0xFFBDBDBD);

  /// Disabled text color for both themes
  static const Color TEXT_DISABLED = Color(0xFF9E9E9E);

  /// Divider color for separators
  static const Color DIVIDER_LIGHT = Color(0xFFE0E0E0);
  static const Color DIVIDER_DARK = Color(0xFF333333);

  /// Creates the light theme configuration.
  ///
  /// Returns a [ThemeData] with light mode colors, typography,
  /// and component themes optimized for the Poker Dice game.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: PRIMARY_COLOR,
      brightness: Brightness.light,
      primary: PRIMARY_COLOR,
      secondary: ACCENT_COLOR,
      error: ERROR_COLOR,
      surface: BACKGROUND_LIGHT,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BACKGROUND_LIGHT,

      // Typography
      textTheme: _buildLightTextTheme(),

      // Component themes
      cardTheme: _buildCardTheme(light: true),
      buttonTheme: _buildButtonTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),

      // Input theme
      inputDecorationTheme: _buildInputDecorationTheme(light: true),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: PRIMARY_COLOR,
        foregroundColor: TEXT_PRIMARY_LIGHT,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: TEXT_PRIMARY_LIGHT,
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: DIVIDER_LIGHT,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Creates the dark theme configuration.
  ///
  /// Returns a [ThemeData] with dark mode colors, typography,
  /// and component themes optimized for the Poker Dice game.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: PRIMARY_COLOR,
      brightness: Brightness.dark,
      primary: PRIMARY_COLOR,
      secondary: ACCENT_COLOR,
      error: ERROR_COLOR,
      surface: BACKGROUND_DARK,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BACKGROUND_DARK,

      // Typography
      textTheme: _buildDarkTextTheme(),

      // Component themes
      cardTheme: _buildCardTheme(light: false),
      buttonTheme: _buildButtonTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),

      // Input theme
      inputDecorationTheme: _buildInputDecorationTheme(light: false),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: PRIMARY_COLOR,
        foregroundColor: TEXT_PRIMARY_DARK,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: TEXT_PRIMARY_DARK,
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: DIVIDER_DARK,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Builds the text theme for light mode.
  static TextTheme _buildLightTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: TEXT_PRIMARY_LIGHT,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: TEXT_PRIMARY_LIGHT,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: TEXT_PRIMARY_LIGHT,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: TEXT_PRIMARY_LIGHT,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: TEXT_PRIMARY_LIGHT,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: TEXT_PRIMARY_LIGHT,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: TEXT_PRIMARY_LIGHT,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: TEXT_PRIMARY_LIGHT,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TEXT_PRIMARY_LIGHT,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: TEXT_PRIMARY_LIGHT,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TEXT_PRIMARY_LIGHT,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TEXT_SECONDARY_LIGHT,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TEXT_PRIMARY_LIGHT,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TEXT_SECONDARY_LIGHT,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: TEXT_SECONDARY_LIGHT,
      ),
    );
  }

  /// Builds the text theme for dark mode.
  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: TEXT_PRIMARY_DARK,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: TEXT_PRIMARY_DARK,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: TEXT_PRIMARY_DARK,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: TEXT_PRIMARY_DARK,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: TEXT_PRIMARY_DARK,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: TEXT_PRIMARY_DARK,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: TEXT_PRIMARY_DARK,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: TEXT_PRIMARY_DARK,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TEXT_PRIMARY_DARK,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: TEXT_PRIMARY_DARK,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TEXT_PRIMARY_DARK,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TEXT_SECONDARY_DARK,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TEXT_PRIMARY_DARK,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TEXT_SECONDARY_DARK,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: TEXT_SECONDARY_DARK,
      ),
    );
  }

  /// Builds the card theme configuration.
  static CardThemeData _buildCardTheme({required bool light}) {
    return CardThemeData(
      color: light ? SURFACE_LIGHT : SURFACE_DARK,
      elevation: 4,
      shadowColor: light ? Colors.black12 : Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Builds the base button theme.
  static ButtonThemeData _buildButtonTheme() {
    return ButtonThemeData(
      height: 48,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// Builds the elevated button theme.
  static ElevatedButtonThemeData _buildElevatedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PRIMARY_COLOR,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Builds the outlined button theme.
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PRIMARY_COLOR,
        side: const BorderSide(color: PRIMARY_COLOR, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Builds the text button theme.
  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PRIMARY_COLOR,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// Builds the input decoration theme.
  static InputDecorationTheme _buildInputDecorationTheme({
    required bool light,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: light ? SURFACE_LIGHT : SURFACE_DARK,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: light ? DIVIDER_LIGHT : DIVIDER_DARK),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: light ? DIVIDER_LIGHT : DIVIDER_DARK),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: PRIMARY_COLOR, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ERROR_COLOR),
      ),
      labelStyle: GoogleFonts.poppins(
        color: light ? TEXT_SECONDARY_LIGHT : TEXT_SECONDARY_DARK,
      ),
      hintStyle: GoogleFonts.poppins(
        color: light ? TEXT_SECONDARY_LIGHT : TEXT_SECONDARY_DARK,
      ),
    );
  }
}
