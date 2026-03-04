import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/features/score/score_repository.dart';
import 'package:poker_dice/features/score/score_provider.dart';

@GenerateMocks([SharedPreferences])
import 'persistence_test.mocks.dart';

void main() {
  group('Persistence Cycle Tests', () {
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test(
      'save high score, create new repository instance, load returns same score',
      () async {
        // Setup: Save a high score
        when(
          mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 5000),
        ).thenAnswer((_) async => true);
        when(
          mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
        ).thenReturn(5000);

        final repository1 = ScoreRepository(mockSharedPreferences);
        await repository1.saveHighScore(5000);

        // Simulate restart: create new repository instance with same SharedPreferences
        final repository2 = ScoreRepository(mockSharedPreferences);
        final loadedScore = await repository2.loadHighScore();

        expect(loadedScore, 5000);
        verify(
          mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 5000),
        ).called(1);
        verify(
          mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
        ).called(1);
      },
    );

    test('persistence survives restart (new repository instance)', () async {
      const testScore = 7500;

      // Phase 1: Save score
      when(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, testScore),
      ).thenAnswer((_) async => true);

      final repositoryBeforeRestart = ScoreRepository(mockSharedPreferences);
      await repositoryBeforeRestart.saveHighScore(testScore);

      // Phase 2: Simulate app restart - new instance reads persisted data
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(testScore);

      final repositoryAfterRestart = ScoreRepository(mockSharedPreferences);
      final persistedScore = await repositoryAfterRestart.loadHighScore();

      expect(persistedScore, testScore);
    });

    test('clear then load returns 0', () async {
      // Setup: Save a score first
      when(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 3000),
      ).thenAnswer((_) async => true);

      final repository = ScoreRepository(mockSharedPreferences);
      await repository.saveHighScore(3000);

      // Clear the score
      when(
        mockSharedPreferences.remove(ScoreRepository.HIGH_SCORE_KEY),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(null);

      await repository.clearHighScore();
      final scoreAfterClear = await repository.loadHighScore();

      expect(scoreAfterClear, 0);
      verify(
        mockSharedPreferences.remove(ScoreRepository.HIGH_SCORE_KEY),
      ).called(1);
    });
  });

  group('Provider Integration Tests', () {
    late ProviderContainer container;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('scoreProvider loads initial state correctly', () async {
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(2500);

      final score = await container.read(scoreProvider.future);
      expect(score, 2500);
    });

    test('state updates correctly when saving', () async {
      // Initial state
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(0);

      await container.read(scoreProvider.future);

      // Save new high score
      when(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 4000),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(4000);

      await container.read(scoreProvider.notifier).saveHighScore(4000);

      final state = await container.read(scoreProvider.future);
      expect(state, 4000);

      verify(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 4000),
      ).called(1);
    });

    test('state updates correctly when clearing', () async {
      // Initial state with a score
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(5000);

      await container.read(scoreProvider.future);

      // Clear the score
      when(
        mockSharedPreferences.remove(ScoreRepository.HIGH_SCORE_KEY),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(null);

      await container.read(scoreProvider.notifier).clearHighScore();

      final state = await container.read(scoreProvider.future);
      expect(state, 0);

      verify(
        mockSharedPreferences.remove(ScoreRepository.HIGH_SCORE_KEY),
      ).called(1);
    });

    test('scoreProvider state persists across container recreations', () async {
      const testScore = 6000;

      // First container: save score
      when(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, testScore),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(testScore);

      final container1 = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );

      await container1.read(scoreProvider.notifier).saveHighScore(testScore);
      final scoreInFirstContainer = await container1.read(scoreProvider.future);
      expect(scoreInFirstContainer, testScore);

      // Second container: load score (simulates app restart)
      final container2 = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );

      final scoreInSecondContainer = await container2.read(
        scoreProvider.future,
      );
      expect(scoreInSecondContainer, testScore);

      container1.dispose();
      container2.dispose();
    });
  });

  group('Error Handling Tests', () {
    late MockSharedPreferences mockSharedPreferences;
    late ProviderContainer container;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('error handling when SharedPreferences setInt fails', () async {
      // Initial load succeeds
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(0);

      await container.read(scoreProvider.future);

      // Save fails
      when(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 1000),
      ).thenAnswer((_) async => false);

      await container.read(scoreProvider.notifier).saveHighScore(1000);

      // State should contain error
      final asyncValue = container.read(scoreProvider);
      expect(asyncValue.hasError, true);
    });

    test('error handling when SharedPreferences getInt fails', () async {
      // Load fails - use a closure that throws
      when(mockSharedPreferences.getInt(any)).thenAnswer((_) {
        throw Exception('SharedPreferences read error');
      });

      // The error is caught by the provider during build
      // Await the future - it will complete (with error handled by provider)
      try {
        await container.read(scoreProvider.future);
      } catch (_) {
        // Expected - the provider catches the error
      }

      // The error is caught by the provider, so we check the state
      final asyncValue = container.read(scoreProvider);
      expect(asyncValue.hasError, true);
    });

    test('error handling when SharedPreferences remove fails', () async {
      // Initial load succeeds
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(500);

      await container.read(scoreProvider.future);

      // Clear fails
      when(
        mockSharedPreferences.remove(ScoreRepository.HIGH_SCORE_KEY),
      ).thenAnswer((_) async => false);

      await container.read(scoreProvider.notifier).clearHighScore();

      // State should contain error
      final asyncValue = container.read(scoreProvider);
      expect(asyncValue.hasError, true);
    });

    test('repository throws StateError when save fails', () async {
      when(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, 999),
      ).thenAnswer((_) async => false);

      final repository = ScoreRepository(mockSharedPreferences);

      expect(
        () async => await repository.saveHighScore(999),
        throwsA(isA<StateError>()),
      );
    });

    test('repository throws StateError when load fails', () async {
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenThrow(Exception('Read error'));

      final repository = ScoreRepository(mockSharedPreferences);

      expect(
        () async => await repository.loadHighScore(),
        throwsA(isA<StateError>()),
      );
    });

    test('repository throws StateError when clear fails', () async {
      when(
        mockSharedPreferences.remove(ScoreRepository.HIGH_SCORE_KEY),
      ).thenAnswer((_) async => false);

      final repository = ScoreRepository(mockSharedPreferences);

      expect(
        () async => await repository.clearHighScore(),
        throwsA(isA<StateError>()),
      );
    });
  });
}
