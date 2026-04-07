import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/data/high_score_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late HighScoreRepository repository;

  setUpAll(() {
    // Set up fake shared preferences
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    repository = HighScoreRepository.instance;
    await repository.initialize();
    await repository.clearHighScores();
  });

  tearDown(() async {
    await repository.clearHighScores();
  });

  group('HighScore Model', () {
    test('toJson converts HighScore to JSON correctly', () {
      final score = HighScore(score: 1000, date: DateTime(2024, 1, 15, 10, 30));

      final json = score.toJson();

      expect(json['score'], equals(1000));
      expect(json['date'], equals('2024-01-15T10:30:00.000'));
    });

    test('fromJson creates HighScore from JSON correctly', () {
      final json = {'score': 1500, 'date': '2024-02-20T14:45:00.000'};

      final score = HighScore.fromJson(json);

      expect(score.score, equals(1500));
      expect(score.date, equals(DateTime(2024, 2, 20, 14, 45)));
    });

    test('fromJson preserves date correctly', () {
      final originalDate = DateTime(2024, 6, 15, 8, 30, 45);
      final json = {'score': 2000, 'date': originalDate.toIso8601String()};

      final score = HighScore.fromJson(json);

      expect(score.date.year, equals(originalDate.year));
      expect(score.date.month, equals(originalDate.month));
      expect(score.date.day, equals(originalDate.day));
      expect(score.date.hour, equals(originalDate.hour));
      expect(score.date.minute, equals(originalDate.minute));
    });
  });

  group('HighScoreRepository - Initialize storage', () {
    test('initialize sets up SharedPreferences', () async {
      expect(repository.prefs, isNotNull);
    });

    test('initialize allows reading and writing', () async {
      await repository.prefs!.setString('test_key', 'test_value');
      expect(repository.prefs!.getString('test_key'), equals('test_value'));
    });
  });

  group('HighScoreRepository - Save single score', () {
    test('saveScore stores a new score', () async {
      await repository.saveScore(500, DateTime(2024, 3, 10));

      final scores = await repository.getHighScores();

      expect(scores.length, equals(1));
      expect(scores.first.score, equals(500));
    });

    test('saveScore stores date correctly', () async {
      final testDate = DateTime(2024, 5, 20, 15, 30);
      await repository.saveScore(750, testDate);

      final scores = await repository.getHighScores();

      expect(scores.first.date.year, equals(testDate.year));
      expect(scores.first.date.month, equals(testDate.month));
      expect(scores.first.date.day, equals(testDate.day));
    });
  });

  group('HighScoreRepository - Save multiple scores', () {
    test('saveScore adds multiple scores to the list', () async {
      await repository.saveScore(300, DateTime(2024, 1, 1));
      await repository.saveScore(500, DateTime(2024, 1, 2));
      await repository.saveScore(400, DateTime(2024, 1, 3));

      final scores = await repository.getHighScores();

      expect(scores.length, equals(3));
    });

    test('saveScore maintains correct order after multiple saves', () async {
      await repository.saveScore(300, DateTime(2024, 1, 1));
      await repository.saveScore(500, DateTime(2024, 1, 2));
      await repository.saveScore(400, DateTime(2024, 1, 3));

      final scores = await repository.getHighScores();

      expect(scores[0].score, equals(500));
      expect(scores[1].score, equals(400));
      expect(scores[2].score, equals(300));
    });
  });

  group('HighScoreRepository - Get high scores returns sorted list', () {
    test('getHighScores returns scores in descending order', () async {
      await repository.saveScore(200, DateTime(2024, 1, 1));
      await repository.saveScore(800, DateTime(2024, 1, 2));
      await repository.saveScore(500, DateTime(2024, 1, 3));
      await repository.saveScore(1000, DateTime(2024, 1, 4));

      final scores = await repository.getHighScores();

      expect(scores[0].score, equals(1000));
      expect(scores[1].score, equals(800));
      expect(scores[2].score, equals(500));
      expect(scores[3].score, equals(200));
    });

    test('getHighScores sorts by score regardless of save order', () async {
      await repository.saveScore(100, DateTime(2024, 1, 1));
      await repository.saveScore(900, DateTime(2024, 1, 2));
      await repository.saveScore(500, DateTime(2024, 1, 3));
      await repository.saveScore(700, DateTime(2024, 1, 4));
      await repository.saveScore(300, DateTime(2024, 1, 5));

      final scores = await repository.getHighScores();

      for (int i = 0; i < scores.length - 1; i++) {
        expect(scores[i].score, greaterThanOrEqualTo(scores[i + 1].score));
      }
    });
  });

  group('HighScoreRepository - Get high scores limited to 10', () {
    test('getHighScores returns maximum 10 scores', () async {
      for (int i = 0; i < 15; i++) {
        await repository.saveScore(1000 - i, DateTime(2024, 1, i + 1));
      }

      final scores = await repository.getHighScores();

      expect(scores.length, equals(10));
      expect(scores.first.score, equals(1000));
      expect(scores.last.score, equals(991));
    });

    test('getHighScores keeps highest scores when limit exceeded', () async {
      // Add scores from 1 to 15
      for (int i = 1; i <= 15; i++) {
        await repository.saveScore(i, DateTime(2024, 1, i));
      }

      final scores = await repository.getHighScores();

      expect(scores.length, equals(10));
      expect(scores.first.score, equals(15));
      expect(scores.last.score, equals(6));
    });
  });

  group('HighScoreRepository - Clear high scores works', () {
    test('clearHighScores removes all scores', () async {
      await repository.saveScore(500, DateTime(2024, 1, 1));
      await repository.saveScore(750, DateTime(2024, 1, 2));

      await repository.clearHighScores();

      final scores = await repository.getHighScores();
      expect(scores.isEmpty, isTrue);
    });

    test('clearHighScores allows saving new scores after', () async {
      await repository.saveScore(500, DateTime(2024, 1, 1));
      await repository.clearHighScores();
      await repository.saveScore(1000, DateTime(2024, 2, 1));

      final scores = await repository.getHighScores();

      expect(scores.length, equals(1));
      expect(scores.first.score, equals(1000));
    });
  });

  group('HighScoreRepository - Empty storage returns empty list', () {
    test('getHighScores returns empty list when no scores saved', () async {
      final scores = await repository.getHighScores();

      expect(scores, isEmpty);
    });

    test('getHighScores returns empty list after clear', () async {
      await repository.clearHighScores();

      final scores = await repository.getHighScores();

      expect(scores, isEmpty);
    });
  });

  group('HighScoreRepository - Date is stored correctly', () {
    test('date is preserved across save and retrieve', () async {
      final originalDate = DateTime(2024, 12, 25, 18, 30, 45, 500);
      await repository.saveScore(9999, originalDate);

      final scores = await repository.getHighScores();
      final retrievedDate = scores.first.date;

      expect(retrievedDate.year, equals(originalDate.year));
      expect(retrievedDate.month, equals(originalDate.month));
      expect(retrievedDate.day, equals(originalDate.day));
      expect(retrievedDate.hour, equals(originalDate.hour));
      expect(retrievedDate.minute, equals(originalDate.minute));
      expect(retrievedDate.second, equals(originalDate.second));
    });

    test('different dates are stored for different scores', () async {
      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 6, 15);
      final date3 = DateTime(2024, 12, 31);

      await repository.saveScore(100, date1);
      await repository.saveScore(200, date2);
      await repository.saveScore(300, date3);

      final scores = await repository.getHighScores();

      expect(scores[0].date, equals(date3));
      expect(scores[1].date, equals(date2));
      expect(scores[2].date, equals(date1));
    });
  });
}
