import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/src/data/high_score_repository.dart';

void main() {
  group('HighScoreRepository', () {
    late HighScoreRepository repository;

    setUp(() async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      repository = HighScoreRepository();
    });

    test('returns empty list when no scores exist', () async {
      final scores = await repository.getHighScores();
      expect(scores, isEmpty);
    });

    test('saves a single score correctly', () async {
      const testScore = 150;
      final result = await repository.saveScore(testScore);

      expect(result, isTrue);

      final scores = await repository.getHighScores();
      expect(scores.length, equals(1));
      expect(scores.first.score, equals(testScore));
    });

    test('stores multiple scores and sorts by score descending', () async {
      await repository.saveScore(100);
      await repository.saveScore(200);
      await repository.saveScore(150);

      final scores = await repository.getHighScores();

      expect(scores.length, equals(3));
      expect(scores[0].score, equals(200));
      expect(scores[1].score, equals(150));
      expect(scores[2].score, equals(100));
    });

    test('keeps only top 10 scores', () async {
      // Add 15 scores
      for (int i = 1; i <= 15; i++) {
        await repository.saveScore(i * 10);
      }

      final scores = await repository.getHighScores();

      expect(scores.length, equals(10));
      expect(scores.first.score, equals(150));
      expect(scores.last.score, equals(60));
    });

    test('clears all high scores', () async {
      await repository.saveScore(100);
      await repository.saveScore(200);

      final result = await repository.clearHighScores();

      expect(result, isTrue);

      final scores = await repository.getHighScores();
      expect(scores, isEmpty);
    });

    test('scoreQualifies returns true when less than 10 scores', () async {
      await repository.saveScore(100);
      await repository.saveScore(200);

      final qualifies = await repository.scoreQualifies(150);

      expect(qualifies, isTrue);
    });

    test(
      'scoreQualifies returns true when score is higher than lowest',
      () async {
        // Add 10 scores
        for (int i = 1; i <= 10; i++) {
          await repository.saveScore(i * 10);
        }

        // Score of 120 should qualify (higher than lowest of 100)
        final qualifies = await repository.scoreQualifies(120);

        expect(qualifies, isTrue);
      },
    );

    test(
      'scoreQualifies returns false when score is lower than all scores',
      () async {
        // Add 10 scores (10, 20, 30, ..., 100)
        // After sorting, lowest will be 10
        for (int i = 1; i <= 10; i++) {
          await repository.saveScore(i * 10);
        }

        // Score of 5 should not qualify (lower than lowest of 10)
        final qualifies = await repository.scoreQualifies(5);

        expect(qualifies, isFalse);
      },
    );

    test('stores date with each score entry', () async {
      final beforeSave = DateTime.now();
      await repository.saveScore(100);
      final afterSave = DateTime.now();

      final scores = await repository.getHighScores();

      expect(scores.length, equals(1));
      expect(
        scores.first.date.isAfter(beforeSave),
        isTrue,
        reason: 'Date should be after save started',
      );
      expect(
        scores.first.date.isBefore(afterSave.add(const Duration(seconds: 1))),
        isTrue,
        reason: 'Date should be before save ended',
      );
    });

    test('HighScoreEntry equality works correctly', () {
      final entry1 = HighScoreEntry(score: 100, date: DateTime(2024, 1, 1));
      final entry2 = HighScoreEntry(score: 100, date: DateTime(2024, 1, 1));
      final entry3 = HighScoreEntry(score: 200, date: DateTime(2024, 1, 1));
      final entry4 = HighScoreEntry(score: 100, date: DateTime(2024, 1, 2));

      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
      expect(entry1, isNot(equals(entry4)));
    });

    test('HighScoreEntry toJson and fromJson work correctly', () {
      final original = HighScoreEntry(
        score: 250,
        date: DateTime(2024, 6, 15, 10, 30),
      );

      final json = original.toJson();
      final fromJson = HighScoreEntry.fromJson(json);

      expect(fromJson.score, equals(original.score));
      expect(fromJson.date, equals(original.date));
    });
  });
}
