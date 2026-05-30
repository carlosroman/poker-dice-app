import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:poker_dice/providers/settings_provider.dart';
import 'package:poker_dice/services/storage_service.dart';
import 'package:poker_dice/widgets/high_scores_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/storage_service_test.mocks.dart';

void main() {
  group('HighScoresDialog', () {
    late MockSharedPreferences mockPrefs;
    late StorageService storageService;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      storageService = StorageService(prefs: mockPrefs);
    });

    testWidgets('displays loading state when data is loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith(
              (ref) => SettingsNotifier(
                storageService,
                initialState: const AsyncValue.loading(),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const HighScoresDialog(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('High Scores'), findsOneWidget);
    });

    testWidgets('displays error state when data load fails',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith(
              (ref) => SettingsNotifier(
                storageService,
                initialState: AsyncValue.error(
                  Exception('Load failed'),
                  StackTrace.empty,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const HighScoresDialog(),
            ),
          ),
        ),
      );

      expect(find.text('Unable to load high scores'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays empty state when no scores exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith(
              (ref) => SettingsNotifier(
                storageService,
                initialState: const AsyncValue.data([]),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const HighScoresDialog(),
            ),
          ),
        ),
      );

      expect(find.text('No high scores yet'), findsOneWidget);
      expect(find.text('Complete a game to set a score'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
    });

    testWidgets('displays scores list when scores exist',
        (WidgetTester tester) async {
      final List<HighScore> scores = [
        HighScore(score: 300, timestamp: DateTime(2024, 1, 15)),
        HighScore(score: 250, timestamp: DateTime(2024, 2, 20)),
        HighScore(score: 200, timestamp: DateTime(2024, 3, 10)),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith(
              (ref) => SettingsNotifier(
                storageService,
                initialState: AsyncValue.data(scores),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const HighScoresDialog(),
            ),
          ),
        ),
      );

      expect(find.text('High Scores'), findsOneWidget);
      expect(find.text('300'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
      expect(find.text('2024-01-15'), findsOneWidget);
      expect(find.text('2024-02-20'), findsOneWidget);
      expect(find.text('2024-03-10'), findsOneWidget);
    });

    testWidgets('displays rank numbers correctly',
        (WidgetTester tester) async {
      final List<HighScore> scores = [
        HighScore(score: 300, timestamp: DateTime(2024, 1, 15)),
        HighScore(score: 250, timestamp: DateTime(2024, 2, 20)),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith(
              (ref) => SettingsNotifier(
                storageService,
                initialState: AsyncValue.data(scores),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const HighScoresDialog(),
            ),
          ),
        ),
      );

      // Rank numbers should be in CircleAvatars
      final Finder rankAvatars = find.byType(CircleAvatar);
      expect(rankAvatars, findsNWidgets(2));
    });

    testWidgets('shows close button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith(
              (ref) => SettingsNotifier(
                storageService,
                initialState: const AsyncValue.data([]),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const HighScoresDialog(),
            ),
          ),
        ),
      );

      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('displays top 3 ranks with premium icons',
        (WidgetTester tester) async {
      final List<HighScore> scores = [
        HighScore(score: 300, timestamp: DateTime(2024, 1, 15)),
        HighScore(score: 250, timestamp: DateTime(2024, 2, 20)),
        HighScore(score: 200, timestamp: DateTime(2024, 3, 10)),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith(
              (ref) => SettingsNotifier(
                storageService,
                initialState: AsyncValue.data(scores),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const HighScoresDialog(),
            ),
          ),
        ),
      );

      // Top 3 should have workspace_premium icon
      expect(find.byIcon(Icons.workspace_premium), findsNWidgets(3));
    });

    testWidgets('displays 4th rank and below with star_border icon',
        (WidgetTester tester) async {
      final List<HighScore> scores = [
        HighScore(score: 300, timestamp: DateTime(2024, 1, 15)),
        HighScore(score: 250, timestamp: DateTime(2024, 2, 20)),
        HighScore(score: 200, timestamp: DateTime(2024, 3, 10)),
        HighScore(score: 150, timestamp: DateTime(2024, 4, 5)),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith(
              (ref) => SettingsNotifier(
                storageService,
                initialState: AsyncValue.data(scores),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const HighScoresDialog(),
            ),
          ),
        ),
      );

      // 4th rank should have star_border icon
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });
  });
}
