import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/features/game/data/game_state_repository.dart';
import 'package:poker_dice/features/game/providers/game_state_provider.dart';
import 'package:poker_dice/features/game/models/game_state.dart';
import 'package:poker_dice/features/score/score_provider.dart';

@GenerateMocks([SharedPreferences, GameStateRepository])
import 'game_state_provider_test.mocks.dart';

void main() {
  group('Provider Integration Tests', () {
    late ProviderContainer container;
    late MockSharedPreferences mockSharedPreferences;
    late MockGameStateRepository mockRepository;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      mockRepository = MockGameStateRepository();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          gameStateRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('gameStateProvider loads initial state correctly', () async {
      final gameState = GameState(
        rollsRemaining: 3,
        turnNumber: 1,
        isGameOver: false,
      );
      final jsonString = jsonEncode(gameState.toJson());

      when(mockRepository.loadGameState()).thenAnswer((_) async => gameState);
      when(
        mockSharedPreferences.getString('game_state'),
      ).thenReturn(jsonString);

      final result = await container.read(gameStateProvider.future);

      expect(result, isNotNull);
      expect(result!.rollsRemaining, 3);
      expect(result.turnNumber, 1);
    });

    test('state updates correctly when saving', () async {
      final gameState = GameState(
        rollsRemaining: 2,
        turnNumber: 3,
        isGameOver: false,
      );

      // Initial load
      when(mockRepository.loadGameState()).thenAnswer((_) async => null);
      await container.read(gameStateProvider.future);

      // Save new state
      when(
        mockRepository.saveGameState(gameState),
      ).thenAnswer((_) async => true);

      final success = await container
          .read(gameStateProvider.notifier)
          .saveGameState(gameState);

      expect(success, true);

      final state = container.read(gameStateProvider).value;
      expect(state, isNotNull);
      expect(state!.rollsRemaining, 2);
      expect(state.turnNumber, 3);

      verify(mockRepository.saveGameState(gameState)).called(1);
    });

    test('state updates correctly when clearing', () async {
      final gameState = GameState();

      // Initial load with state
      when(mockRepository.loadGameState()).thenAnswer((_) async => gameState);
      await container.read(gameStateProvider.future);

      // Clear state
      when(mockRepository.clearGameState()).thenAnswer((_) async => true);

      final success = await container
          .read(gameStateProvider.notifier)
          .clearGameState();

      expect(success, true);

      final state = container.read(gameStateProvider).value;
      expect(state, isNull);

      verify(mockRepository.clearGameState()).called(1);
    });

    test('Provider state persists across container recreations', () async {
      const testTurnNumber = 7;
      final savedState = GameState(
        rollsRemaining: 1,
        turnNumber: testTurnNumber,
        isGameOver: false,
      );
      final jsonString = jsonEncode(savedState.toJson());

      // First container: save state
      when(mockRepository.loadGameState()).thenAnswer((_) async => null);
      when(
        mockRepository.saveGameState(savedState),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.getString('game_state'),
      ).thenReturn(jsonString);

      final container1 = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          gameStateRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      await container1.read(gameStateProvider.future);
      await container1
          .read(gameStateProvider.notifier)
          .saveGameState(savedState);

      final stateInFirstContainer = await container1.read(
        gameStateProvider.future,
      );
      expect(stateInFirstContainer, isNotNull);
      expect(stateInFirstContainer!.turnNumber, testTurnNumber);

      // Second container: load state (simulates app restart)
      when(mockRepository.loadGameState()).thenAnswer((_) async => savedState);

      final container2 = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          gameStateRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final stateInSecondContainer = await container2.read(
        gameStateProvider.future,
      );
      expect(stateInSecondContainer, isNotNull);
      expect(stateInSecondContainer!.turnNumber, testTurnNumber);

      container1.dispose();
      container2.dispose();
    });
  });

  group('Error Handling Tests', () {
    late ProviderContainer container;
    late MockSharedPreferences mockSharedPreferences;
    late MockGameStateRepository mockRepository;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      mockRepository = MockGameStateRepository();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          gameStateRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('error handling when repository save fails', () async {
      // Initial load succeeds
      when(mockRepository.loadGameState()).thenAnswer((_) async => null);
      await container.read(gameStateProvider.future);

      // Save fails - returns false
      final gameState = GameState();
      when(
        mockRepository.saveGameState(gameState),
      ).thenAnswer((_) async => false);

      final success = await container
          .read(gameStateProvider.notifier)
          .saveGameState(gameState);

      expect(success, false);

      // State should remain unchanged (no error set when returning false)
      final asyncValue = container.read(gameStateProvider);
      expect(asyncValue.hasError, false);
    });

    test('error handling when repository load fails', () async {
      // Load fails
      when(mockRepository.loadGameState()).thenAnswer((_) async {
        throw Exception('Repository load error');
      });

      // The error is caught by the provider during build
      try {
        await container.read(gameStateProvider.future);
      } catch (_) {
        // Expected - the provider catches the error
      }

      // The error is caught by the provider, so we check the state
      final asyncValue = container.read(gameStateProvider);
      expect(asyncValue.hasError, true);
    });

    test('error handling when repository clear fails', () async {
      // Initial load succeeds
      final gameState = GameState();
      when(mockRepository.loadGameState()).thenAnswer((_) async => gameState);
      await container.read(gameStateProvider.future);

      // Clear fails - returns false
      when(mockRepository.clearGameState()).thenAnswer((_) async => false);

      final success = await container
          .read(gameStateProvider.notifier)
          .clearGameState();

      expect(success, false);

      // State should remain unchanged (no error set when returning false)
      final asyncValue = container.read(gameStateProvider);
      expect(asyncValue.hasError, false);
    });

    test('repository returns false when save throws exception', () async {
      // Initial load succeeds
      when(mockRepository.loadGameState()).thenAnswer((_) async => null);
      await container.read(gameStateProvider.future);

      // Save throws exception
      final gameState = GameState();
      when(
        mockRepository.saveGameState(gameState),
      ).thenThrow(Exception('Unexpected save error'));

      final success = await container
          .read(gameStateProvider.notifier)
          .saveGameState(gameState);

      expect(success, false);

      final asyncValue = container.read(gameStateProvider);
      expect(asyncValue.hasError, true);
    });

    test('repository returns false when clear throws exception', () async {
      // Initial load succeeds
      final gameState = GameState();
      when(mockRepository.loadGameState()).thenAnswer((_) async => gameState);
      await container.read(gameStateProvider.future);

      // Clear throws exception
      when(
        mockRepository.clearGameState(),
      ).thenThrow(Exception('Unexpected clear error'));

      final success = await container
          .read(gameStateProvider.notifier)
          .clearGameState();

      expect(success, false);

      final asyncValue = container.read(gameStateProvider);
      expect(asyncValue.hasError, true);
    });

    test('provider handles JSON decode error during load', () async {
      // Mock repository that throws on load
      when(mockRepository.loadGameState()).thenAnswer((_) async {
        throw FormatException('Invalid JSON format');
      });

      try {
        await container.read(gameStateProvider.future);
      } catch (_) {
        // Expected - the provider catches the error
      }

      final asyncValue = container.read(gameStateProvider);
      expect(asyncValue.hasError, true);
    });
  });

  group('GameStatePersistenceNotifier methods', () {
    late ProviderContainer container;
    late MockGameStateRepository mockRepository;

    setUp(() {
      mockRepository = MockGameStateRepository();

      container = ProviderContainer(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'saveGameState updates state to loading then data on success',
      () async {
        when(mockRepository.loadGameState()).thenAnswer((_) async => null);
        await container.read(gameStateProvider.future);

        final gameState = GameState(turnNumber: 5);
        when(
          mockRepository.saveGameState(gameState),
        ).thenAnswer((_) async => true);

        // Before save, state should be null
        expect(container.read(gameStateProvider).value, isNull);

        await container
            .read(gameStateProvider.notifier)
            .saveGameState(gameState);

        // After save, state should be the saved game state
        final state = container.read(gameStateProvider).value;
        expect(state, isNotNull);
        expect(state!.turnNumber, 5);
      },
    );

    test(
      'clearGameState updates state to loading then null on success',
      () async {
        final initialGame = GameState(turnNumber: 3);
        when(
          mockRepository.loadGameState(),
        ).thenAnswer((_) async => initialGame);
        await container.read(gameStateProvider.future);

        expect(container.read(gameStateProvider).value, isNotNull);

        when(mockRepository.clearGameState()).thenAnswer((_) async => true);

        await container.read(gameStateProvider.notifier).clearGameState();

        final state = container.read(gameStateProvider).value;
        expect(state, isNull);
      },
    );

    test('saveGameState preserves all game state fields', () async {
      when(mockRepository.loadGameState()).thenAnswer((_) async => null);
      await container.read(gameStateProvider.future);

      final gameState = GameState(
        rollsRemaining: 1,
        isTurnActive: false,
        turnNumber: 10,
        isGameOver: true,
        pendingSelection: 5,
      );

      when(
        mockRepository.saveGameState(gameState),
      ).thenAnswer((_) async => true);

      await container.read(gameStateProvider.notifier).saveGameState(gameState);

      final savedState = container.read(gameStateProvider).value;
      expect(savedState, isNotNull);
      expect(savedState!.rollsRemaining, 1);
      expect(savedState.isTurnActive, false);
      expect(savedState.turnNumber, 10);
      expect(savedState.isGameOver, true);
      expect(savedState.pendingSelection, 5);
    });
  });
}
