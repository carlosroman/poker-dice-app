import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/services/storage_service.dart';

void main() {
  late StorageService storageService;

  setUpAll(() async {
    // Set up mock shared preferences
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.getInstance();
  });

  tearDownAll(() async {
    await storageService.clearAll();
  });

  group('HighScoreEntry Tests', () {
    test('testHighScoreEntryCreation', () {
      final entry = HighScoreEntry(
        playerName: 'TestPlayer',
        score: 1500,
        date: DateTime(2024, 1, 15, 10, 30),
      );

      expect(entry.playerName, 'TestPlayer');
      expect(entry.score, 1500);
      expect(entry.date, DateTime(2024, 1, 15, 10, 30));
    });

    test('testHighScoreEntrySerialization', () {
      final entry = HighScoreEntry(
        playerName: 'TestPlayer',
        score: 1500,
        date: DateTime(2024, 1, 15, 10, 30),
      );

      final map = entry.toMap();

      expect(map['playerName'], 'TestPlayer');
      expect(map['score'], 1500);
      expect(map['date'], '2024-01-15T10:30:00.000');
    });

    test('testHighScoreEntryDeserialization', () {
      final map = {
        'playerName': 'TestPlayer',
        'score': 1500,
        'date': '2024-01-15T10:30:00.000',
      };

      final entry = HighScoreEntry.fromMap(map);

      expect(entry.playerName, 'TestPlayer');
      expect(entry.score, 1500);
      expect(entry.date, DateTime(2024, 1, 15, 10, 30));
    });

    test('testHighScoreEntryCopyWith', () {
      final entry = HighScoreEntry(
        playerName: 'TestPlayer',
        score: 1500,
        date: DateTime(2024, 1, 15),
      );

      final copied = entry.copyWith(score: 2000);

      expect(copied.playerName, 'TestPlayer');
      expect(copied.score, 2000);
      expect(copied.date, DateTime(2024, 1, 15));
    });

    test('testHighScoreEntryEquality', () {
      final entry1 = HighScoreEntry(
        playerName: 'TestPlayer',
        score: 1500,
        date: DateTime(2024, 1, 15),
      );
      final entry2 = HighScoreEntry(
        playerName: 'TestPlayer',
        score: 1500,
        date: DateTime(2024, 1, 15),
      );
      final entry3 = HighScoreEntry(
        playerName: 'DifferentPlayer',
        score: 1500,
        date: DateTime(2024, 1, 15),
      );

      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
    });

    test('testHighScoreEntryToString', () {
      final entry = HighScoreEntry(
        playerName: 'TestPlayer',
        score: 1500,
        date: DateTime(2024, 1, 15),
      );

      expect(
        entry.toString(),
        'HighScoreEntry(playerName: TestPlayer, score: 1500, date: 2024-01-15 00:00:00.000)',
      );
    });
  });

  group('StorageService High Score Tests', () {
    test('testGetHighScoresReturnsEmptyListWhenEmpty', () async {
      await storageService.clearHighScores();

      final scores = await storageService.getHighScores();

      expect(scores, isEmpty);
    });

    test('testSaveAndRetrieveHighScore', () async {
      await storageService.clearHighScores();

      await storageService.saveHighScore('Player1', 1000);

      final scores = await storageService.getHighScores();

      expect(scores.length, 1);
      expect(scores.first.playerName, 'Player1');
      expect(scores.first.score, 1000);
    });

    test('testMultipleHighScoresPersist', () async {
      await storageService.clearHighScores();

      await storageService.saveHighScore('Player1', 1000);
      await storageService.saveHighScore('Player2', 1500);
      await storageService.saveHighScore('Player3', 1200);

      final scores = await storageService.getHighScores();

      expect(scores.length, 3);
      // Scores should be sorted by score descending
      expect(scores[0].playerName, 'Player2');
      expect(scores[0].score, 1500);
      expect(scores[1].playerName, 'Player3');
      expect(scores[1].score, 1200);
      expect(scores[2].playerName, 'Player1');
      expect(scores[2].score, 1000);
    });

    test('testGetHighScoresReturnsTop10Only', () async {
      await storageService.clearHighScores();

      // Add 15 high scores
      for (int i = 0; i < 15; i++) {
        await storageService.saveHighScore('Player$i', 2000 - i);
      }

      final scores = await storageService.getHighScores();

      expect(scores.length, 10);
      // Should only contain the top 10 scores
      expect(scores.first.score, 2000);
      expect(scores.last.score, 1991);
    });

    test('testClearHighScores', () async {
      await storageService.clearHighScores();

      await storageService.saveHighScore('Player1', 1000);
      await storageService.saveHighScore('Player2', 1500);

      await storageService.clearHighScores();

      final scores = await storageService.getHighScores();
      expect(scores, isEmpty);
    });

    test('testHighScoresSortedByScoreDescending', () async {
      await storageService.clearHighScores();

      await storageService.saveHighScore('Player1', 500);
      await storageService.saveHighScore('Player2', 2000);
      await storageService.saveHighScore('Player3', 1000);

      final scores = await storageService.getHighScores();

      expect(scores[0].score, 2000);
      expect(scores[1].score, 1000);
      expect(scores[2].score, 500);
    });

    test('testHighScoresPersistAcrossInstances', () async {
      await storageService.clearHighScores();

      await storageService.saveHighScore('PersistentPlayer', 3000);

      // Get a new instance
      final newService = await StorageService.getInstance();

      final scores = await newService.getHighScores();

      expect(scores.length, 1);
      expect(scores.first.playerName, 'PersistentPlayer');
      expect(scores.first.score, 3000);
    });
  });

  group('StorageService Theme Preference Tests', () {
    test('testThemePreferenceDefaultsToFalse', () async {
      await storageService.clearAll();

      final isDarkMode = await storageService.getThemePreference();

      expect(isDarkMode, false);
    });

    test('testSaveAndRetrieveThemePreference', () async {
      await storageService.clearAll();

      await storageService.saveThemePreference(true);

      final isDarkMode = await storageService.getThemePreference();

      expect(isDarkMode, true);
    });

    test('testToggleThemePreference', () async {
      await storageService.clearAll();

      // Initial state
      expect(await storageService.getThemePreference(), false);

      // Save dark mode
      await storageService.saveThemePreference(true);
      expect(await storageService.getThemePreference(), true);

      // Save light mode
      await storageService.saveThemePreference(false);
      expect(await storageService.getThemePreference(), false);
    });
  });

  group('StorageService Edge Cases', () {
    test('testSaveHighScoreWithZeroScore', () async {
      await storageService.clearHighScores();

      await storageService.saveHighScore('ZeroPlayer', 0);

      final scores = await storageService.getHighScores();

      expect(scores.length, 1);
      expect(scores.first.score, 0);
    });

    test('testSaveHighScoreWithPlayerNameContainingSpaces', () async {
      await storageService.clearHighScores();

      await storageService.saveHighScore('John Doe Smith', 1500);

      final scores = await storageService.getHighScores();

      expect(scores.length, 1);
      expect(scores.first.playerName, 'John Doe Smith');
    });

    test('testSaveHighScoreWithVeryHighScore', () async {
      await storageService.clearHighScores();

      await storageService.saveHighScore('HighScorer', 999999);

      final scores = await storageService.getHighScores();

      expect(scores.length, 1);
      expect(scores.first.score, 999999);
    });

    test('testClearAllRemovesAllData', () async {
      await storageService.clearHighScores();
      await storageService.saveHighScore('Player1', 1000);
      await storageService.saveThemePreference(true);

      await storageService.clearAll();

      expect(await storageService.getHighScores(), isEmpty);
      expect(await storageService.getThemePreference(), false);
    });
  });

  group('StorageService Initialization Tests', () {
    test('testGetInstanceReturnsSameInstance', () async {
      final instance1 = await StorageService.getInstance();
      final instance2 = await StorageService.getInstance();

      expect(instance1, equals(instance2));
    });

    test('testStorageServiceInitializedCorrectly', () async {
      final service = await StorageService.getInstance();

      // Should be able to call methods without errors
      expect(service.getHighScores(), completion(isA<List<HighScoreEntry>>()));
      expect(service.getThemePreference(), completion(isA<bool>()));
    });
  });
}
