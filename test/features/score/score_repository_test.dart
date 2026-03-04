import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/features/score/score_repository.dart';

@GenerateMocks([SharedPreferences])
import 'score_repository_test.mocks.dart';

void main() {
  late ScoreRepository scoreRepository;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    scoreRepository = ScoreRepository(mockSharedPreferences);
  });

  group('Save High Score tests', () {
    test('saveHighScore() stores the score correctly', () async {
      when(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 100),
      ).thenAnswer((_) async => true);

      await scoreRepository.saveHighScore(100);

      verify(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 100),
      ).called(1);
    });

    test('saveHighScore() throws on failure', () async {
      when(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 50),
      ).thenAnswer((_) async => false);

      expect(
        () async => await scoreRepository.saveHighScore(50),
        throwsA(isA<StateError>()),
      );
    });

    test('saving multiple scores updates the value', () async {
      when(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 100),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 200),
      ).thenAnswer((_) async => true);

      await scoreRepository.saveHighScore(100);
      await scoreRepository.saveHighScore(200);

      verify(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 100),
      ).called(1);
      verify(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 200),
      ).called(1);
    });
  });

  group('Load High Score tests', () {
    test('loadHighScore() returns saved score', () async {
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(150);

      final score = await scoreRepository.loadHighScore();

      expect(score, 150);
      verify(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).called(1);
    });

    test('loadHighScore() returns 0 when no score exists', () async {
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(null);

      final score = await scoreRepository.loadHighScore();

      expect(score, 0);
    });

    test('loadHighScore() after save returns correct value', () async {
      when(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 300),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(300);

      await scoreRepository.saveHighScore(300);
      final score = await scoreRepository.loadHighScore();

      expect(score, 300);
    });
  });

  group('Clear High Score tests', () {
    test('clearHighScore() removes the stored score', () async {
      when(
        mockSharedPreferences.remove(ScoreRepository.HIGH_SCORE_KEY),
      ).thenAnswer((_) async => true);

      await scoreRepository.clearHighScore();

      verify(
        mockSharedPreferences.remove(ScoreRepository.HIGH_SCORE_KEY),
      ).called(1);
    });

    test('clearHighScore() followed by loadHighScore() returns 0', () async {
      when(
        mockSharedPreferences.remove(ScoreRepository.HIGH_SCORE_KEY),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(null);

      await scoreRepository.clearHighScore();
      final score = await scoreRepository.loadHighScore();

      expect(score, 0);
    });

    test('clearHighScore() throws on failure', () async {
      when(
        mockSharedPreferences.remove(ScoreRepository.HIGH_SCORE_KEY),
      ).thenAnswer((_) async => false);

      expect(
        () async => await scoreRepository.clearHighScore(),
        throwsA(isA<StateError>()),
      );
    });
  });
}
