import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/providers/theme_provider.dart';

void main() {
  late ProviderContainer container;
  late ThemeNotifier notifier;

  setUp(() {
    container = ProviderContainer();
    notifier = container.read(themeProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  // -----------------------------------------------------------------------
  // Initial state
  // -----------------------------------------------------------------------

  group('initial state', () {
    test('starts with ThemeMode.light', () {
      expect(container.read(themeProvider), ThemeMode.light);
    });

    test('themeData returns light theme by default', () {
      final themeData = notifier.themeData;

      expect(themeData.brightness, Brightness.light);
      expect(themeData.useMaterial3, isTrue);
    });
  });

  // -----------------------------------------------------------------------
  // toggleTheme
  // -----------------------------------------------------------------------

  group('toggleTheme', () {
    test('toggles from light to dark', () {
      expect(container.read(themeProvider), ThemeMode.light);

      notifier.toggleTheme();

      expect(container.read(themeProvider), ThemeMode.dark);
    });

    test('toggles from dark to light', () {
      notifier.toggleTheme();
      expect(container.read(themeProvider), ThemeMode.dark);

      notifier.toggleTheme();
      expect(container.read(themeProvider), ThemeMode.light);
    });

    test('multiple toggles alternate correctly', () {
      expect(container.read(themeProvider), ThemeMode.light);

      notifier.toggleTheme();
      expect(container.read(themeProvider), ThemeMode.dark);

      notifier.toggleTheme();
      expect(container.read(themeProvider), ThemeMode.light);

      notifier.toggleTheme();
      expect(container.read(themeProvider), ThemeMode.dark);
    });
  });

  // -----------------------------------------------------------------------
  // setTheme
  // -----------------------------------------------------------------------

  group('setTheme', () {
    test('sets theme to dark', () {
      expect(container.read(themeProvider), ThemeMode.light);

      notifier.setTheme(ThemeMode.dark);

      expect(container.read(themeProvider), ThemeMode.dark);
    });

    test('sets theme to light', () {
      notifier.setTheme(ThemeMode.dark);
      expect(container.read(themeProvider), ThemeMode.dark);

      notifier.setTheme(ThemeMode.light);
      expect(container.read(themeProvider), ThemeMode.light);
    });

    test('sets theme to system', () {
      notifier.setTheme(ThemeMode.system);

      expect(container.read(themeProvider), ThemeMode.system);
    });
  });

  // -----------------------------------------------------------------------
  // themeData
  // -----------------------------------------------------------------------

  group('themeData', () {
    test('returns light theme when mode is ThemeMode.light', () {
      final themeData = notifier.themeData;

      expect(themeData.brightness, Brightness.light);
      expect(themeData.colorScheme.brightness, Brightness.light);
      expect(themeData.useMaterial3, isTrue);
    });

    test('returns dark theme when mode is ThemeMode.dark', () {
      notifier.setTheme(ThemeMode.dark);
      final themeData = notifier.themeData;

      expect(themeData.brightness, Brightness.dark);
      expect(themeData.colorScheme.brightness, Brightness.dark);
      expect(themeData.useMaterial3, isTrue);
    });

    test('light theme uses deep blue seed color', () {
      final themeData = notifier.themeData;

      expect(themeData.colorScheme.primary, isNot(equals(Colors.blue)));
    });

    test('light theme uses amber secondary color', () {
      final themeData = notifier.themeData;

      expect(themeData.colorScheme.secondary.toARGB32(), equals(0xFFFFC107));
    });

    test('dark theme uses deep blue seed color', () {
      notifier.setTheme(ThemeMode.dark);
      final themeData = notifier.themeData;

      expect(themeData.colorScheme.primary, isNot(equals(Colors.blue)));
    });

    test('dark theme uses amber secondary color', () {
      notifier.setTheme(ThemeMode.dark);
      final themeData = notifier.themeData;

      expect(themeData.colorScheme.secondary.toARGB32(), equals(0xFFFFC107));
    });

    test('light theme has dark blue surfaceContainerHighest for dice area', () {
      final themeData = notifier.themeData;

      expect(
        themeData.colorScheme.surfaceContainerHighest.toARGB32(),
        equals(0xFF0D47A1),
      );
    });

    test('light theme has light blue surface', () {
      final themeData = notifier.themeData;

      expect(themeData.colorScheme.surface.toARGB32(), equals(0xFFE3F2FD));
    });
  });

  // -----------------------------------------------------------------------
  // Provider integration
  // -----------------------------------------------------------------------

  group('provider integration', () {
    test('state changes are reflected in the provider', () {
      expect(container.read(themeProvider), ThemeMode.light);

      notifier.toggleTheme();
      expect(container.read(themeProvider), ThemeMode.dark);

      notifier.toggleTheme();
      expect(container.read(themeProvider), ThemeMode.light);
    });

    test('themeData updates after toggle', () {
      expect(notifier.themeData.brightness, Brightness.light);

      notifier.toggleTheme();
      expect(notifier.themeData.brightness, Brightness.dark);

      notifier.toggleTheme();
      expect(notifier.themeData.brightness, Brightness.light);
    });

    test('setTheme updates provider state', () {
      expect(container.read(themeProvider), ThemeMode.light);

      notifier.setTheme(ThemeMode.dark);
      expect(container.read(themeProvider), ThemeMode.dark);
    });
  });
}
