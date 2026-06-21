/// Theme provider using Riverpod's StateNotifier pattern.
///
/// Manages light/dark theme state and provides Material 3
/// color schemes matching the app's design tokens.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider that exposes the [ThemeNotifier].
///
/// The notifier holds a [ThemeMode] value and exposes
/// [ThemeNotifier.toggleTheme] and [ThemeNotifier.setTheme] methods.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

/// Notifier responsible for theme state.
///
/// Defaults to [ThemeMode.light]. On every state change,
/// [autoSave] is invoked (currently a no-op stub for persistence).
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  /// Toggles between light and dark theme.
  void toggleTheme() {
    state = (state == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    _autoSave(state);
  }

  /// Sets a specific [ThemeMode].
  void setTheme(ThemeMode mode) {
    state = mode;
    _autoSave(state);
  }

  /// Returns the current [ThemeData] based on [state].
  ThemeData get themeData => (state == ThemeMode.dark) ? darkTheme : lightTheme;

  /// Light theme with deep blue primary and amber accents.
  ///
  /// Uses a darker seed color and explicit surface colors to ensure
  /// the dice area has a dark blue background with high contrast
  /// against white dice faces and black pips.
  static ThemeData get lightTheme {
    final base = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D47A1), // darker blue for contrast
      brightness: Brightness.light,
      secondary: const Color(0xFFFFC107), // amber
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: base.copyWith(
        surface: const Color(0xFFE3F2FD), // light blue surface
        surfaceContainerHighest:
            const Color(0xFF0D47A1), // dark blue dice area
      ),
    );
  }

  /// Dark theme with deep blue primary and amber accents.
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0), // deep blue
      brightness: Brightness.dark,
      secondary: const Color(0xFFFFC107), // amber
    ),
  );

  /// Placeholder for persistence layer.
  ///
  /// Currently a no-op; will be replaced with shared_preferences
  /// integration in a future iteration.
  void _autoSave(ThemeMode mode) {
    // Stub: persist mode to local storage.
  }
}
