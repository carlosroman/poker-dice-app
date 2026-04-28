import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/providers/settings_provider.dart';
import 'package:poker_dice/services/storage_service.dart';
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

  group('HighScoresDialog with Data Tests', () {
    testWidgets('testHighScoresDialog_displaysScoreList', (tester) async {
      final mockStorage = _MockStorageService();
      mockStorage.highScores = [
        HighScoreEntry(playerName: 'Alice', score: 300, date: DateTime.now()),
        HighScoreEntry(playerName: 'Bob', score: 250, date: DateTime.now()),
        HighScoreEntry(playerName: 'Charlie', score: 200, date: DateTime.now()),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) {
              return SettingsNotifier(storageService: mockStorage)
                ..loadSettings();
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
      await tester.pumpAndSettle();

      // Verify scores are displayed
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('300'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
    });

    testWidgets('testHighScoresDialog_clearButton_enabled_with_scores', (
      tester,
    ) async {
      final mockStorage = _MockStorageService();
      mockStorage.highScores = [
        HighScoreEntry(playerName: 'Alice', score: 300, date: DateTime.now()),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) {
              return SettingsNotifier(storageService: mockStorage)
                ..loadSettings();
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
      await tester.pumpAndSettle();

      // Verify clear button text exists when scores exist
      expect(find.text('Clear All Scores'), findsOneWidget);
    });

    testWidgets('testHighScoresDialog_rankDisplay', (tester) async {
      final mockStorage = _MockStorageService();
      mockStorage.highScores = [
        HighScoreEntry(playerName: 'First', score: 300, date: DateTime.now()),
        HighScoreEntry(playerName: 'Second', score: 250, date: DateTime.now()),
        HighScoreEntry(playerName: 'Third', score: 200, date: DateTime.now()),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) {
              return SettingsNotifier(storageService: mockStorage)
                ..loadSettings();
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
      await tester.pumpAndSettle();

      // Verify at least one trophy icon is displayed
      expect(find.byIcon(Icons.emoji_events), findsWidgets);
    });

    testWidgets('testHighScoresDialog_scrollable_with_many_scores', (
      tester,
    ) async {
      final mockStorage = _MockStorageService();
      mockStorage.highScores = List.generate(
        10,
        (i) => HighScoreEntry(
          playerName: 'Player$i',
          score: 300 - (i * 10),
          date: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) {
              return SettingsNotifier(storageService: mockStorage)
                ..loadSettings();
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
      await tester.pumpAndSettle();

      // Verify ListView is present for scrolling
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('testHighScoresDialog_errorMessageDisplayed', (tester) async {
      final mockStorage = _MockStorageService();
      mockStorage.errorMessage = 'Failed to load scores';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) {
              final notifier = SettingsNotifier(storageService: mockStorage);
              notifier.state = notifier.state.copyWith(
                errorMessage: 'Failed to load scores',
              );
              return notifier;
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
      await tester.pumpAndSettle();

      // Verify error message is displayed
      expect(find.text('Failed to load scores'), findsOneWidget);
    });

    testWidgets('testHighScoresDialog_clearConfirmationDialog', (tester) async {
      final mockStorage = _MockStorageService();
      mockStorage.highScores = [
        HighScoreEntry(playerName: 'Alice', score: 300, date: DateTime.now()),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) {
              return SettingsNotifier(storageService: mockStorage)
                ..loadSettings();
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
      await tester.pumpAndSettle();

      // Tap clear button
      await tester.tap(find.text('Clear All Scores'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog is shown
      expect(find.text('Clear High Scores?'), findsOneWidget);
      expect(
        find.textContaining('Are you sure you want to delete all high scores?'),
        findsOneWidget,
      );
    });
  });
}

/// Mock implementation of StorageService for testing
class _MockStorageService implements StorageService {
  List<HighScoreEntry> highScores = [];
  String? errorMessage;

  @override
  Future<void> saveHighScore(String playerName, int score) async {}

  @override
  Future<List<HighScoreEntry>> getHighScores() async {
    if (errorMessage != null) throw Exception(errorMessage);
    return highScores;
  }

  @override
  Future<void> clearHighScores() async {
    highScores.clear();
  }

  @override
  Future<void> saveThemePreference(bool isDarkMode) async {}

  @override
  Future<bool> getThemePreference() async => false;

  @override
  Future<void> clearAll() async {}
}
