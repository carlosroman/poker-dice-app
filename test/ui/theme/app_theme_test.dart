import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('has correct primary colors', () {
      expect(AppTheme.primaryLight, const Color(0xFF1E88E5));
      expect(AppTheme.primaryDark, const Color(0xFF1565C0));
    });

    test('has correct accent colors', () {
      expect(AppTheme.accentYellow, const Color(0xFFFFB74D));
      expect(AppTheme.accentOrange, const Color(0xFFFF9800));
    });

    test('has correct score box colors', () {
      expect(AppTheme.scoreBoxLightBlue, const Color(0xFF4FC3F7));
      expect(AppTheme.scoreTextWhite, const Color(0xFFFFFFFF));
    });

    test('has correct die colors', () {
      expect(AppTheme.dieFace, const Color(0xFFFFFFFF));
      expect(AppTheme.dieDot, const Color(0xFF000000));
      expect(AppTheme.dieBorder, const Color(0xFFFF9800));
    });

    test('lightTheme creates valid ThemeData', () {
      final theme = AppTheme.lightTheme();

      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppTheme.primaryLight);
    });

    test('darkTheme creates valid ThemeData', () {
      final theme = AppTheme.darkTheme();

      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppTheme.primaryLight);
    });

    test('appBarTheme has correct properties', () {
      final lightTheme = AppTheme.lightTheme();
      final appBarTheme = lightTheme.appBarTheme;

      expect(appBarTheme.backgroundColor, Colors.transparent);
      expect(appBarTheme.elevation, 0);
      expect(appBarTheme.iconTheme?.color, AppTheme.textOnPrimary);
    });

    test('textTheme has required text styles', () {
      final theme = AppTheme.lightTheme();
      final textTheme = theme.textTheme;

      expect(textTheme.displayLarge, isNotNull);
      expect(textTheme.displayMedium, isNotNull);
      expect(textTheme.displaySmall, isNotNull);
      expect(textTheme.headlineMedium, isNotNull);
      expect(textTheme.headlineSmall, isNotNull);
      expect(textTheme.titleLarge, isNotNull);
      expect(textTheme.titleMedium, isNotNull);
      expect(textTheme.bodyLarge, isNotNull);
      expect(textTheme.bodyMedium, isNotNull);
      expect(textTheme.labelLarge, isNotNull);
    });

    test('textTheme styles have correct font sizes', () {
      final theme = AppTheme.lightTheme();
      final textTheme = theme.textTheme;

      expect(textTheme.displayLarge?.fontSize, 32);
      expect(textTheme.displayMedium?.fontSize, 28);
      expect(textTheme.displaySmall?.fontSize, 24);
      expect(textTheme.headlineMedium?.fontSize, 20);
      expect(textTheme.headlineSmall?.fontSize, 18);
      expect(textTheme.titleLarge?.fontSize, 16);
      expect(textTheme.titleMedium?.fontSize, 14);
      expect(textTheme.bodyLarge?.fontSize, 16);
      expect(textTheme.bodyMedium?.fontSize, 14);
      expect(textTheme.labelLarge?.fontSize, 14);
    });

    test('elevatedButtonTheme has correct properties', () {
      final theme = AppTheme.lightTheme();
      final buttonStyle = theme.elevatedButtonTheme.style;

      expect(buttonStyle?.backgroundColor?.resolve({}), AppTheme.surfaceDark);
      expect(buttonStyle?.foregroundColor?.resolve({}), AppTheme.textOnPrimary);
    });

    test('outlinedButtonTheme has correct properties', () {
      final theme = AppTheme.lightTheme();
      final buttonStyle = theme.outlinedButtonTheme.style;

      expect(buttonStyle?.foregroundColor?.resolve({}), AppTheme.accentOrange);
    });
  });

  group('AppSpacing', () {
    test('has correct spacing values', () {
      expect(AppSpacing.xs, 2.0);
      expect(AppSpacing.sm, 4.0);
      expect(AppSpacing.md, 8.0);
      expect(AppSpacing.lg, 12.0);
      expect(AppSpacing.xl, 16.0);
      expect(AppSpacing.xxl, 24.0);
      expect(AppSpacing.xxxl, 32.0);
    });
  });

  group('AppTypography', () {
    test('has correct font size values', () {
      expect(AppTypography.small, 12.0);
      expect(AppTypography.medium, 14.0);
      expect(AppTypography.large, 16.0);
      expect(AppTypography.extraLarge, 20.0);
      expect(AppTypography.title, 24.0);
      expect(AppTypography.display, 32.0);
    });
  });

  group('getThemeForSystem', () {
    testWidgets('returns light theme for light system', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Test'))),
      );

      final theme = AppTheme.getThemeForSystem();
      expect(theme.colorScheme.brightness, Brightness.light);
    });
  });
}
