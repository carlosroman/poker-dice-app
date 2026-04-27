import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/providers/settings_provider.dart';
import 'package:poker_dice/widgets/high_scores_dialog.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HighScoresDialog Tests', () {
    testWidgets('testHighScoresDialog_displaysEmptyMessage', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showHighScoresDialog(context),
                  child: const Text('Show Scores'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Show Scores'));
      await tester.pumpAndSettle();

      // Verify empty message is displayed
      expect(find.text('High Scores'), findsOneWidget);
      expect(find.text('No high scores yet!'), findsOneWidget);
    });

    testWidgets('testHighScoresDialog_dismissesOnClose', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showHighScoresDialog(context),
                  child: const Text('Show Scores'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Show Scores'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);

      // Close the dialog using the X button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('testHighScoresDialog_displaysLoadingState', (tester) async {
      // Create a provider override that simulates loading
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) {
              return SettingsNotifier()..loadSettings();
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showHighScoresDialog(context),
                  child: const Text('Show Scores'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Show Scores'));
      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('testHighScoresDialog_theming', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showHighScoresDialog(context),
                  child: const Text('Show Scores'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Show Scores'));
      await tester.pumpAndSettle();

      // Verify dialog is displayed with proper theming
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('High Scores'), findsOneWidget);
    });
  });

  group('showHighScoresDialog Function Tests', () {
    testWidgets('testShowHighScoresDialog_opensCorrectly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showHighScoresDialog(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(HighScoresDialog), findsOneWidget);
    });
  });

  group('HighScoresDialog Button Tests', () {
    testWidgets('testHighScoresDialog_clearButton_exists', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showHighScoresDialog(context),
                  child: const Text('Show Scores'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Show Scores'));
      await tester.pumpAndSettle();

      // Verify clear button exists (should be disabled when empty)
      expect(find.text('Clear All Scores'), findsOneWidget);
    });
  });
}
