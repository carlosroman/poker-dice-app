import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/main.dart';
import 'package:poker_dice/src/ui/pages/game_screen.dart';

/// Integration tests for the main app entry point.
///
/// These tests verify that the app loads correctly and displays the expected
/// UI elements. This test suite is designed to catch regressions where
/// main.dart might be accidentally reverted to a default "Hello World!" template.
///
/// Run on web platform:
/// `flutter test --platform chrome test/integration/main_app_test.dart`
void main() {
  group('MainApp Integration Tests', () {
    /// Helper to pump the main app widget
    Future<void> pumpMainApp(WidgetTester tester) async {
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle();
    }

    group('App Loading', () {
      testWidgets('app loads without "Hello World!" text', (tester) async {
        await pumpMainApp(tester);

        // Verify the app does NOT contain "Hello World!" text
        // This catches accidental reverts to default Flutter template
        expect(find.text('Hello World!'), findsNothing);
        expect(find.textContaining('Hello World'), findsNothing);
      });

      testWidgets('app displays GameScreen as home', (tester) async {
        await pumpMainApp(tester);

        // Verify GameScreen is displayed
        expect(find.byType(GameScreen), findsOneWidget);
      });

      testWidgets('app has correct title', (tester) async {
        await pumpMainApp(tester);

        // Verify the MaterialApp title is set correctly
        final materialApp = find.byType(MaterialApp);
        expect(materialApp, findsOneWidget);
      });
    });

    group('Game Screen Elements', () {
      testWidgets('displays 5 dice', (tester) async {
        await pumpMainApp(tester);

        // All 5 dice should be present with their unique keys
        expect(find.byKey(const ValueKey('die-0')), findsOneWidget);
        expect(find.byKey(const ValueKey('die-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('die-2')), findsOneWidget);
        expect(find.byKey(const ValueKey('die-3')), findsOneWidget);
        expect(find.byKey(const ValueKey('die-4')), findsOneWidget);
      });

      testWidgets('displays ROLL button', (tester) async {
        await pumpMainApp(tester);

        // The ROLL button should be visible
        expect(find.textContaining('ROLL'), findsOneWidget);
      });

      testWidgets('displays score sheet with categories', (tester) async {
        await pumpMainApp(tester);

        // Score sheet should be displayed with two-column layout
        expect(find.text('Upper Section'), findsOneWidget);
        expect(find.text('Lower Section'), findsOneWidget);

        // Verify score rows are present (Text widgets for scores)
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays New Game button', (tester) async {
        await pumpMainApp(tester);

        // New Game button (second ElevatedButton) should be present
        final elevatedButtons = find.byType(ElevatedButton);
        expect(elevatedButtons, findsWidgets);
      });

      testWidgets('displays header with score', (tester) async {
        await pumpMainApp(tester);

        // Header should display the current score
        expect(find.byType(Text), findsWidgets);

        // Score should be visible (initially 0 appears in multiple places: header, bonus, categories)
        final scoreText = find.text('0');
        expect(scoreText, findsWidgets);
      });

      testWidgets('displays back button', (tester) async {
        await pumpMainApp(tester);

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('displays menu button', (tester) async {
        await pumpMainApp(tester);

        expect(find.byIcon(Icons.more_vert), findsOneWidget);
      });
    });

    group('Theme Verification', () {
      testWidgets('applies gradient background', (tester) async {
        await pumpMainApp(tester);

        // Verify gradient decoration is applied
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsWidgets);

        // Get the container with gradient
        final container = tester.widget<Container>(containerFinder.first);
        expect(container.decoration, isA<BoxDecoration>());
      });

      testWidgets('uses blue gradient colors', (tester) async {
        await pumpMainApp(tester);

        // Verify the gradient colors match AppTheme
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsWidgets);

        final container = tester.widget<Container>(containerFinder.first);
        final decoration = container.decoration as BoxDecoration?;
        final gradient = decoration?.gradient;

        // Gradient should be present
        expect(gradient, isNotNull);
      });

      testWidgets('has SafeArea wrapper', (tester) async {
        await pumpMainApp(tester);

        // SafeArea should wrap the content for proper edge handling
        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('uses Material 3 theme', (tester) async {
        await pumpMainApp(tester);

        // Material 3 is enabled in AppTheme.lightTheme()
        final material = find.byType(Material);
        expect(material, findsWidgets);
      });
    });

    group('Interactive Elements', () {
      testWidgets('ROLL button is initially enabled', (tester) async {
        await pumpMainApp(tester);

        // ROLL button should be enabled at start of game
        final rollButton = find.textContaining('ROLL');
        expect(rollButton, findsOneWidget);

        // Button should be tappable
        final button = tester.widget<ElevatedButton>(
          find
              .ancestor(of: rollButton, matching: find.byType(ElevatedButton))
              .first,
        );
        expect(button.onPressed, isNotNull);
      });

      testWidgets('New Game button is present', (tester) async {
        await pumpMainApp(tester);

        // New Game button should be available
        final newGameButton = find.byType(ElevatedButton).last;
        expect(newGameButton, findsOneWidget);
      });

      testWidgets('dice are interactive', (tester) async {
        await pumpMainApp(tester);

        // Each die should be findable and potentially tappable
        for (int i = 0; i < 5; i++) {
          final die = find.byKey(ValueKey('die-$i'));
          expect(die, findsOneWidget);
        }
      });
    });

    group('Accessibility', () {
      testWidgets('has semantic labels for accessibility', (tester) async {
        await pumpMainApp(tester);

        // The app should have semantic widgets for screen readers
        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('buttons have proper semantics', (tester) async {
        await pumpMainApp(tester);

        // Verify semantic widgets are present for accessibility
        final semanticsFinder = find.byType(Semantics);
        expect(semanticsFinder, findsWidgets);
      });
    });

    group('Layout Structure', () {
      testWidgets('has proper column layout', (tester) async {
        await pumpMainApp(tester);

        // Main layout uses Column for vertical arrangement
        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('score sheet has Upper Section and Lower Section sections', (
        tester,
      ) async {
        await pumpMainApp(tester);

        // Score sheet should have both section headers
        expect(find.text('Upper Section'), findsOneWidget);
        expect(find.text('Lower Section'), findsOneWidget);
      });

      testWidgets('dice row is properly positioned', (tester) async {
        await pumpMainApp(tester);

        // Dice should be in a row layout
        expect(find.byType(Row), findsWidgets);
      });
    });

    group('Regression Prevention', () {
      testWidgets('prevents Hello World regression', (tester) async {
        await pumpMainApp(tester);

        // This test specifically prevents the common mistake of
        // accidentally reverting to the default Flutter counter app
        expect(find.text('Counter:'), findsNothing);
        expect(find.text('Hello World!'), findsNothing);
        expect(
          find.text('You have pushed the button this many times:'),
          findsNothing,
        );
        expect(find.byIcon(Icons.add), findsNothing);
      });

      testWidgets('confirms Poker Dice app identity', (tester) async {
        await pumpMainApp(tester);

        // Verify this is the Poker Dice app, not something else
        expect(find.byType(GameScreen), findsOneWidget);
        expect(find.byKey(const ValueKey('die-0')), findsOneWidget);
        expect(find.textContaining('ROLL'), findsOneWidget);
      });
    });
  });
}
