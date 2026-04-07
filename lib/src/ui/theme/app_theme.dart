import 'package:flutter/material.dart';

/// Application theme configuration for Poker Dice (Yatzy) game.
///
/// Provides light and dark theme variants with consistent styling
/// for colors, typography, spacing, and component themes.
///
/// ## Color Palette
/// - **Primary**: Deep red (#B71C1C) - Poker theme main color
/// - **Secondary**: Gold (#FFD700) - Accent and premium feel
/// - **Success**: Green (#388E3C) - Positive states
/// - **Error**: Red (#D32F2F) - Error states
///
/// ## Typography
/// Uses Roboto font family with consistent sizing:
/// - Heading Large: 32px (page titles)
/// - Heading Medium: 24px (section titles)
/// - Body Large: 16px (main content)
/// - Body Small: 12px (captions)
///
/// ## Spacing System
/// Based on 4px grid:
/// - XS: 4px, SM: 8px, MD: 16px, LG: 24px, XL: 32px, XXL: 48px
///
/// Example:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme(),
///   darkTheme: AppTheme.darkTheme(),
///   themeMode: ThemeMode.system,
/// )
/// ```
class AppTheme {
  /// Private constructor to prevent instantiation.
  AppTheme._();

  //region Color Definitions

  /// Primary color - Main game color (deep red for poker theme).
  ///
  /// Used for:
  /// - Primary buttons
  /// - App bar background (light theme)
  /// - Selected item highlights
  static const Color primaryColor = Color(0xFFB71C1C);

  /// Secondary color - Accent color (gold for premium feel).
  ///
  /// Used for:
  /// - Bonus indicators
  /// - Secondary buttons
  /// - Trophy and achievement icons
  static const Color secondaryColor = Color(0xFFFFD700);

  /// Background color - Main app background (light theme).
  static const Color backgroundColor = Color(0xFFF5F5F5);

  /// Surface color - Card and panel backgrounds (light theme).
  static const Color surfaceColor = Color(0xFFFFFFFF);

  /// Error color - Error states and validation.
  static const Color errorColor = Color(0xFFD32F2F);

  /// Success color - Success states and positive feedback.
  static const Color successColor = Color(0xFF388E3C);

  //region Text Colors

  /// Primary text color - Main content text (light theme).
  static const Color textPrimary = Color(0xFF212121);

  /// Secondary text color - Less important text, labels, captions.
  static const Color textSecondary = Color(0xFF757575);

  /// On surface text - Text on dark surfaces (dark theme).
  static const Color textOnSurface = Color(0xFFFFFFFF);

  //endregion

  //region Dice Colors

  /// Dice face color - Background of dice.
  static const Color diceFaceColor = Color(0xFFFFFFFF);

  /// Dice dot color - Color of dots on dice faces.
  static const Color diceDotColor = Color(0xFF212121);

  /// Dice border color - Border of unselected dice.
  static const Color diceBorderColor = Color(0xFFE0E0E0);

  /// Dice selected color - Highlight for held dice.
  static const Color diceSelectedColor = Color(0xFF1976D2);

  //endregion

  //region UI Colors

  /// Score background color - Background for score cards.
  static const Color scoreBackgroundColor = Color(0xFFFAFAFA);

  /// Selected color - Highlight for selected items (checkboxes, rows).
  static const Color selectedColor = Color(0xFF1976D2);

  /// Disabled color - Disabled state color for buttons and inputs.
  static const Color disabledColor = Color(0xFFBDBDBD);

  /// Card background color - Game card backgrounds.
  static const Color cardBackgroundColor = Color(0xFF263238);

  //endregion

  //endregion

  //region Typography

  /// Font family for the application (Roboto).
  static const String fontFamily = 'Roboto';

  /// Heading font size - Large headings (page titles).
  static const double headingLarge = 32.0;

  /// Heading font size - Medium headings (section titles).
  static const double headingMedium = 24.0;

  /// Heading font size - Small headings (subsections).
  static const double headingSmall = 20.0;

  /// Body font size - Large body text (main content).
  static const double bodyLarge = 16.0;

  /// Body font size - Medium body text (secondary content).
  static const double bodyMedium = 14.0;

  /// Body font size - Small body text (captions, labels).
  static const double bodySmall = 12.0;

  /// Button font size.
  static const double buttonSize = 16.0;

  //endregion

  //region Spacing

  /// Extra small spacing - Tiny gaps (4px).
  static const double spacingXs = 4.0;

  /// Small spacing - Small gaps (8px).
  static const double spacingSm = 8.0;

  /// Medium spacing - Medium gaps (16px).
  static const double spacingMd = 16.0;

  /// Large spacing - Large gaps (24px).
  static const double spacingLg = 24.0;

  /// Extra large spacing - Extra large gaps (32px).
  static const double spacingXl = 32.0;

  /// Extra extra large spacing - Page margins (48px).
  static const double spacingXxl = 48.0;

  //endregion

  //region Border Radius

  /// Small border radius - Small corners (4px).
  static const double radiusSm = 4.0;

  /// Medium border radius - Medium corners (8px).
  static const double radiusMd = 8.0;

  /// Large border radius - Large corners (12px).
  static const double radiusLg = 12.0;

  /// Extra large border radius - Extra large corners (16px).
  static const double radiusXl = 16.0;

  /// Full border radius - Fully rounded (32px+).
  static const double radiusFull = 32.0;

  //endregion

  //region Shadows

  /// Small shadow - Subtle elevation (cards, small elements).
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 2.0, offset: Offset(0, 1)),
  ];

  /// Medium shadow - Standard elevation (buttons, score cards).
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4.0, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 8.0, offset: Offset(0, 4)),
  ];

  /// Large shadow - High elevation (floating elements, dialogs).
  static const List<BoxShadow> shadowLarge = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 12.0, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x14000000), blurRadius: 24.0, offset: Offset(0, 8)),
  ];

  //endregion

  /// Creates the light theme configuration.
  ///
  /// Returns a [ThemeData] configured for light mode with:
  /// - Poker-themed color scheme (red and gold accents)
  /// - Readable typography with proper hierarchy
  /// - Consistent spacing using 4px grid
  /// - Component themes for cards, buttons, and checkboxes
  ///
  /// Returns:
  /// A [ThemeData] instance configured for light mode.
  ///
  /// Example:
  /// ```dart
  /// MaterialApp(
  ///   theme: AppTheme.lightTheme(),
  /// )
  /// ```
  static ThemeData lightTheme() {
    final ColorScheme colorScheme = ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black87,
      onSurface: textPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: fontFamily,

      // Text Themes
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: headingLarge,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        displayMedium: TextStyle(
          fontSize: headingMedium,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        displaySmall: TextStyle(
          fontSize: headingSmall,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        headlineMedium: TextStyle(
          fontSize: headingSmall,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        titleLarge: TextStyle(
          fontSize: bodyLarge,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: bodyLarge,
          fontWeight: FontWeight.normal,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: bodyMedium,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          fontFamily: fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: bodySmall,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          fontFamily: fontFamily,
        ),
        labelLarge: TextStyle(
          fontSize: buttonSize,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
      ),

      // Component Themes
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: buttonSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: buttonSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingSm,
            vertical: spacingXs,
          ),
          textStyle: const TextStyle(
            fontSize: buttonSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: headingMedium,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: fontFamily,
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: spacingSm,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Creates the dark theme configuration.
  ///
  /// Returns a [ThemeData] configured for dark mode with:
  /// - Dark poker-themed color scheme
  /// - High contrast for readability
  /// - Consistent spacing using 4px grid
  /// - Component themes adapted for dark backgrounds
  ///
  /// Returns:
  /// A [ThemeData] instance configured for dark mode.
  ///
  /// Example:
  /// ```dart
  /// MaterialApp(
  ///   darkTheme: AppTheme.darkTheme(),
  ///   themeMode: ThemeMode.system,
  /// )
  /// ```
  static ThemeData darkTheme() {
    final ColorScheme colorScheme = ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFF1E1E1E),
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black87,
      onSurface: textOnSurface,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: fontFamily,

      // Text Themes
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: headingLarge,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
          fontFamily: fontFamily,
        ),
        displayMedium: TextStyle(
          fontSize: headingMedium,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
          fontFamily: fontFamily,
        ),
        displaySmall: TextStyle(
          fontSize: headingSmall,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFFFFF),
          fontFamily: fontFamily,
        ),
        headlineMedium: TextStyle(
          fontSize: headingSmall,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFFFFF),
          fontFamily: fontFamily,
        ),
        titleLarge: TextStyle(
          fontSize: bodyLarge,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE0E0E0),
          fontFamily: fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: bodyLarge,
          fontWeight: FontWeight.normal,
          color: Color(0xFFE0E0E0),
          fontFamily: fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: bodyMedium,
          fontWeight: FontWeight.normal,
          color: Color(0xFFB0B0B0),
          fontFamily: fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: bodySmall,
          fontWeight: FontWeight.normal,
          color: Color(0xFFB0B0B0),
          fontFamily: fontFamily,
        ),
        labelLarge: TextStyle(
          fontSize: buttonSize,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFFFFF),
          fontFamily: fontFamily,
        ),
      ),

      // Component Themes
      cardTheme: CardThemeData(
        color: const Color(0xFF2C2C2C),
        elevation: 2,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: Color(0xFF424242), width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: buttonSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryColor,
          side: const BorderSide(color: secondaryColor, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: buttonSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingSm,
            vertical: spacingXs,
          ),
          textStyle: const TextStyle(
            fontSize: buttonSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: secondaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
        hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black45,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: headingMedium,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: fontFamily,
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F1F1F),
        selectedItemColor: secondaryColor,
        unselectedItemColor: Color(0xFFB0B0B0),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
        thickness: 1,
        space: spacingSm,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
