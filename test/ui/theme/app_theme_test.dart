import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('lightTheme', () {
      test('returns non-null ThemeData', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme, isNotNull);
      });

      test('has correct brightness (Brightness.light)', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.brightness, equals(Brightness.light));
      });

      test('has useMaterial3 enabled', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.useMaterial3, isTrue);
      });

      test('has correct primary color', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.colorScheme.primary, equals(AppTheme.primaryColor));
      });

      test('has correct secondary color', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.colorScheme.secondary, equals(AppTheme.secondaryColor));
      });

      test('has correct surface color', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.colorScheme.surface, equals(AppTheme.surfaceColor));
      });

      test('has correct error color', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.colorScheme.error, equals(AppTheme.errorColor));
      });

      test('has scaffold background color configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.scaffoldBackgroundColor, equals(AppTheme.backgroundColor));
      });

      test('has fontFamily configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(
          theme.textTheme.bodyLarge?.fontFamily,
          equals(AppTheme.fontFamily),
        );
      });

      test('has textTheme configured with non-null styles', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.textTheme, isNotNull);
        expect(theme.textTheme.bodyLarge, isNotNull);
        expect(theme.textTheme.bodyMedium, isNotNull);
        expect(theme.textTheme.titleLarge, isNotNull);
      });

      test('has cardTheme configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.cardTheme, isNotNull);
      });

      test('has elevatedButtonTheme configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.elevatedButtonTheme, isNotNull);
      });

      test('has outlinedButtonTheme configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.outlinedButtonTheme, isNotNull);
      });

      test('has textButtonTheme configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.textButtonTheme, isNotNull);
      });

      test('has checkboxTheme configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.checkboxTheme, isNotNull);
      });

      test('has inputDecorationTheme configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.inputDecorationTheme, isNotNull);
      });

      test('has appBarTheme configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.appBarTheme, isNotNull);
      });

      test('has bottomNavigationBarTheme configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.bottomNavigationBarTheme, isNotNull);
      });

      test('has floatingActionButtonTheme configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.floatingActionButtonTheme, isNotNull);
      });

      test('has dividerTheme configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.dividerTheme, isNotNull);
      });

      test('has snackBarTheme configured', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.snackBarTheme, isNotNull);
      });
    });

    group('darkTheme', () {
      test('returns non-null ThemeData', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme, isNotNull);
      });

      test('has correct brightness (Brightness.dark)', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.brightness, equals(Brightness.dark));
      });

      test('has useMaterial3 enabled', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.useMaterial3, isTrue);
      });

      test('has correct primary color', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.colorScheme.primary, equals(AppTheme.primaryColor));
      });

      test('has correct secondary color', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.colorScheme.secondary, equals(AppTheme.secondaryColor));
      });

      test('has correct surface color', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.colorScheme.surface, equals(const Color(0xFF1E1E1E)));
      });

      test('has correct error color', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.colorScheme.error, equals(AppTheme.errorColor));
      });

      test('has dark scaffold background color configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.scaffoldBackgroundColor, equals(const Color(0xFF121212)));
      });

      test('has fontFamily configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(
          theme.textTheme.bodyLarge?.fontFamily,
          equals(AppTheme.fontFamily),
        );
      });

      test('has textTheme configured with non-null styles', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.textTheme, isNotNull);
        expect(theme.textTheme.bodyLarge, isNotNull);
        expect(theme.textTheme.bodyMedium, isNotNull);
        expect(theme.textTheme.titleLarge, isNotNull);
      });

      test('has cardTheme configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.cardTheme, isNotNull);
      });

      test('has elevatedButtonTheme configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.elevatedButtonTheme, isNotNull);
      });

      test('has outlinedButtonTheme configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.outlinedButtonTheme, isNotNull);
      });

      test('has textButtonTheme configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.textButtonTheme, isNotNull);
      });

      test('has checkboxTheme configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.checkboxTheme, isNotNull);
      });

      test('has inputDecorationTheme configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.inputDecorationTheme, isNotNull);
      });

      test('has appBarTheme configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.appBarTheme, isNotNull);
      });

      test('has bottomNavigationBarTheme configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.bottomNavigationBarTheme, isNotNull);
      });

      test('has floatingActionButtonTheme configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.floatingActionButtonTheme, isNotNull);
      });

      test('has dividerTheme configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.dividerTheme, isNotNull);
      });

      test('has snackBarTheme configured', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.snackBarTheme, isNotNull);
      });
    });

    group('Color Scheme', () {
      test('light theme has onPrimary color', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.colorScheme.onPrimary, isNotNull);
      });

      test('light theme has onSecondary color', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.colorScheme.onSecondary, isNotNull);
      });

      test('light theme has onSurface color', () {
        final ThemeData theme = AppTheme.lightTheme();
        expect(theme.colorScheme.onSurface, isNotNull);
      });

      test('dark theme has onPrimary color', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.colorScheme.onPrimary, isNotNull);
      });

      test('dark theme has onSecondary color', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.colorScheme.onSecondary, isNotNull);
      });

      test('dark theme has onSurface color', () {
        final ThemeData theme = AppTheme.darkTheme();
        expect(theme.colorScheme.onSurface, isNotNull);
      });
    });

    group('Typography', () {
      test('has heading font sizes defined', () {
        expect(AppTheme.headingLarge, greaterThan(24.0));
        expect(AppTheme.headingMedium, greaterThan(18.0));
        expect(AppTheme.headingSmall, greaterThan(14.0));
      });

      test('has body font sizes defined', () {
        expect(AppTheme.bodyLarge, greaterThan(12.0));
        expect(AppTheme.bodyMedium, greaterThan(10.0));
        expect(AppTheme.bodySmall, greaterThan(8.0));
      });

      test('has button font size defined', () {
        expect(AppTheme.buttonSize, greaterThan(12.0));
      });

      test('font sizes follow logical hierarchy', () {
        expect(AppTheme.headingLarge, greaterThan(AppTheme.headingMedium));
        expect(AppTheme.headingMedium, greaterThan(AppTheme.headingSmall));
        expect(AppTheme.headingSmall, greaterThan(AppTheme.bodyLarge));
        expect(AppTheme.bodyLarge, greaterThan(AppTheme.bodyMedium));
        expect(AppTheme.bodyMedium, greaterThan(AppTheme.bodySmall));
      });
    });

    group('Spacing', () {
      test('has spacing values defined', () {
        expect(AppTheme.spacingXs, greaterThan(0));
        expect(AppTheme.spacingSm, greaterThan(AppTheme.spacingXs));
        expect(AppTheme.spacingMd, greaterThan(AppTheme.spacingSm));
        expect(AppTheme.spacingLg, greaterThan(AppTheme.spacingMd));
        expect(AppTheme.spacingXl, greaterThan(AppTheme.spacingLg));
        expect(AppTheme.spacingXxl, greaterThan(AppTheme.spacingXl));
      });

      test('spacing follows 4px grid system', () {
        expect(AppTheme.spacingXs, equals(4.0));
        expect(AppTheme.spacingSm, equals(8.0));
        expect(AppTheme.spacingMd, equals(16.0));
        expect(AppTheme.spacingLg, equals(24.0));
        expect(AppTheme.spacingXl, equals(32.0));
        expect(AppTheme.spacingXxl, equals(48.0));
      });
    });

    group('Border Radius', () {
      test('has border radius values defined', () {
        expect(AppTheme.radiusSm, greaterThan(0));
        expect(AppTheme.radiusMd, greaterThan(AppTheme.radiusSm));
        expect(AppTheme.radiusLg, greaterThan(AppTheme.radiusMd));
        expect(AppTheme.radiusXl, greaterThan(AppTheme.radiusLg));
      });

      test('border radius values are consistent', () {
        expect(AppTheme.radiusSm, equals(4.0));
        expect(AppTheme.radiusMd, equals(8.0));
        expect(AppTheme.radiusLg, equals(12.0));
        expect(AppTheme.radiusXl, equals(16.0));
      });
    });

    group('Color Definitions', () {
      test('primaryColor is defined', () {
        expect(AppTheme.primaryColor, isNotNull);
        expect(AppTheme.primaryColor.toARGB32(), isNotNull);
      });

      test('secondaryColor is defined', () {
        expect(AppTheme.secondaryColor, isNotNull);
        expect(AppTheme.secondaryColor.toARGB32(), isNotNull);
      });

      test('backgroundColor is defined', () {
        expect(AppTheme.backgroundColor, isNotNull);
      });

      test('surfaceColor is defined', () {
        expect(AppTheme.surfaceColor, isNotNull);
      });

      test('errorColor is defined', () {
        expect(AppTheme.errorColor, isNotNull);
      });

      test('diceFaceColor is defined', () {
        expect(AppTheme.diceFaceColor, isNotNull);
      });

      test('diceDotColor is defined', () {
        expect(AppTheme.diceDotColor, isNotNull);
      });

      test('diceSelectedColor is defined', () {
        expect(AppTheme.diceSelectedColor, isNotNull);
      });

      test('selectedColor is defined', () {
        expect(AppTheme.selectedColor, isNotNull);
      });

      test('disabledColor is defined', () {
        expect(AppTheme.disabledColor, isNotNull);
      });
    });

    group('Shadows', () {
      test('shadowSmall is defined', () {
        expect(AppTheme.shadowSmall, isNotNull);
        expect(AppTheme.shadowSmall.length, greaterThan(0));
      });

      test('shadowMedium is defined', () {
        expect(AppTheme.shadowMedium, isNotNull);
        expect(AppTheme.shadowMedium.length, greaterThan(0));
      });

      test('shadowLarge is defined', () {
        expect(AppTheme.shadowLarge, isNotNull);
        expect(AppTheme.shadowLarge.length, greaterThan(0));
      });
    });
  });
}
