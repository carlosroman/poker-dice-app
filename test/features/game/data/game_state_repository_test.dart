import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/features/game/data/game_state_repository.dart';
import 'package:poker_dice/features/game/models/game_state.dart';
import 'package:poker_dice/features/game/models/dice.dart';

@GenerateMocks([SharedPreferences])
import 'game_state_repository_test.mocks.dart';

// Use the public constant from the repository
const _gameStateKey = 'game_state';

void main() {
  late GameStateRepository gameStateRepository;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    gameStateRepository = GameStateRepository(mockSharedPreferences);
  });

  group('Save GameState tests', () {
    test('saveGameState() stores the state correctly', () async {
      final gameState = GameState();
      final jsonString = jsonEncode(gameState.toJson());

      when(
        mockSharedPreferences.setString(_gameStateKey, jsonString),
      ).thenAnswer((_) async => true);

      final result = await gameStateRepository.saveGameState(gameState);

      expect(result, true);
      verify(
        mockSharedPreferences.setString(_gameStateKey, jsonString),
      ).called(1);
    });

    test('saveGameState() returns false on failure', () async {
      final gameState = GameState();
      final jsonString = jsonEncode(gameState.toJson());

      when(
        mockSharedPreferences.setString(_gameStateKey, jsonString),
      ).thenAnswer((_) async => false);

      final result = await gameStateRepository.saveGameState(gameState);

      expect(result, false);
    });

    test('saving multiple states updates the value', () async {
      final gameState1 = GameState(turnNumber: 1);
      final gameState2 = gameState1.resetTurn();
      final jsonString1 = jsonEncode(gameState1.toJson());
      final jsonString2 = jsonEncode(gameState2.toJson());

      when(
        mockSharedPreferences.setString(_gameStateKey, jsonString1),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.setString(_gameStateKey, jsonString2),
      ).thenAnswer((_) async => true);

      final result1 = await gameStateRepository.saveGameState(gameState1);
      final result2 = await gameStateRepository.saveGameState(gameState2);

      expect(result1, true);
      expect(result2, true);

      // Verify both calls were made
      verifyInOrder([
        mockSharedPreferences.setString(_gameStateKey, jsonString1),
        mockSharedPreferences.setString(_gameStateKey, jsonString2),
      ]);
    });
  });

  group('Load GameState tests', () {
    test('loadGameState() returns saved state', () async {
      final gameState = GameState();
      final jsonString = jsonEncode(gameState.toJson());

      when(
        mockSharedPreferences.getString(_gameStateKey),
      ).thenReturn(jsonString);

      final result = await gameStateRepository.loadGameState();

      expect(result, isNotNull);
      expect(result!.dice.length, 5);
      expect(result.rollsRemaining, 3);
      verify(mockSharedPreferences.getString(_gameStateKey)).called(1);
    });

    test('loadGameState() returns null when no state exists', () async {
      when(mockSharedPreferences.getString(_gameStateKey)).thenReturn(null);

      final result = await gameStateRepository.loadGameState();

      expect(result, isNull);
    });

    test(
      'loadGameState() handles corrupted JSON gracefully (returns null)',
      () async {
        when(
          mockSharedPreferences.getString(_gameStateKey),
        ).thenReturn('invalid json {');

        final result = await gameStateRepository.loadGameState();

        expect(result, isNull);
      },
    );

    test('loadGameState() after save returns correct value', () async {
      final gameState = GameState(
        rollsRemaining: 2,
        turnNumber: 5,
        isGameOver: false,
      );
      final jsonString = jsonEncode(gameState.toJson());

      when(
        mockSharedPreferences.setString(_gameStateKey, jsonString),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.getString(_gameStateKey),
      ).thenReturn(jsonString);

      await gameStateRepository.saveGameState(gameState);
      final result = await gameStateRepository.loadGameState();

      expect(result, isNotNull);
      expect(result!.rollsRemaining, 2);
      expect(result.turnNumber, 5);
      expect(result.isGameOver, false);
    });
  });

  group('Clear GameState tests', () {
    test('clearGameState() removes the stored state', () async {
      when(
        mockSharedPreferences.remove(_gameStateKey),
      ).thenAnswer((_) async => true);

      final result = await gameStateRepository.clearGameState();

      expect(result, true);
      verify(mockSharedPreferences.remove(_gameStateKey)).called(1);
    });

    test('clearGameState() followed by loadGameState() returns null', () async {
      when(
        mockSharedPreferences.remove(_gameStateKey),
      ).thenAnswer((_) async => true);
      when(mockSharedPreferences.getString(_gameStateKey)).thenReturn(null);

      await gameStateRepository.clearGameState();
      final result = await gameStateRepository.loadGameState();

      expect(result, isNull);
    });

    test('clearGameState() returns false on failure', () async {
      when(
        mockSharedPreferences.remove(_gameStateKey),
      ).thenAnswer((_) async => false);

      final result = await gameStateRepository.clearGameState();

      expect(result, false);
    });
  });

  group('Round-trip serialization tests', () {
    test(
      'Full GameState round-trip (save → load → verify all fields)',
      () async {
        final originalState = GameState(
          rollsRemaining: 1,
          isTurnActive: false,
          turnNumber: 10,
          isGameOver: true,
          pendingSelection: 7,
        );

        // Fill some categories with scores
        final updatedCategories = List<ScoreCategory>.from(
          originalState.scoreCategories,
        );
        updatedCategories[0] = ScoreCategory(index: 0, score: 18);
        updatedCategories[6] = ScoreCategory(index: 6, score: 30);

        final stateWithScores = GameState(
          dice: originalState.dice,
          rollsRemaining: originalState.rollsRemaining,
          isTurnActive: originalState.isTurnActive,
          scoreCategories: updatedCategories,
          turnNumber: originalState.turnNumber,
          isGameOver: originalState.isGameOver,
          pendingSelection: originalState.pendingSelection,
        );

        final jsonString = jsonEncode(stateWithScores.toJson());

        when(
          mockSharedPreferences.setString(_gameStateKey, jsonString),
        ).thenAnswer((_) async => true);
        when(
          mockSharedPreferences.getString(_gameStateKey),
        ).thenReturn(jsonString);

        await gameStateRepository.saveGameState(stateWithScores);
        final loadedState = await gameStateRepository.loadGameState();

        expect(loadedState, isNotNull);
        expect(loadedState!.rollsRemaining, 1);
        expect(loadedState.isTurnActive, false);
        expect(loadedState.turnNumber, 10);
        expect(loadedState.isGameOver, true);
        expect(loadedState.pendingSelection, 7);
        expect(loadedState.scoreCategories[0].score, 18);
        expect(loadedState.scoreCategories[6].score, 30);
      },
    );

    test('Dice values preserved through serialization', () async {
      // Create dice with specific values
      final customDice = [
        Dice(value: 0, isHeld: false), // 9
        Dice(value: 3, isHeld: true), // Q (held)
        Dice(value: 5, isHeld: false), // A
        Dice(value: 2, isHeld: true), // J (held)
        Dice(value: 4, isHeld: false), // K
      ];

      final gameState = GameState(dice: customDice);
      final jsonString = jsonEncode(gameState.toJson());

      when(
        mockSharedPreferences.setString(_gameStateKey, jsonString),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.getString(_gameStateKey),
      ).thenReturn(jsonString);

      await gameStateRepository.saveGameState(gameState);
      final loadedState = await gameStateRepository.loadGameState();

      expect(loadedState, isNotNull);
      expect(loadedState!.dice.length, 5);
      expect(loadedState.dice[0].value, 0);
      expect(loadedState.dice[0].isHeld, false);
      expect(loadedState.dice[1].value, 3);
      expect(loadedState.dice[1].isHeld, true);
      expect(loadedState.dice[2].value, 5);
      expect(loadedState.dice[3].value, 2);
      expect(loadedState.dice[3].isHeld, true);
      expect(loadedState.dice[4].value, 4);
    });

    test('Score categories preserved through serialization', () async {
      // Create a state with various scored categories
      final categories = <ScoreCategory>[];
      for (int i = 0; i < 13; i++) {
        if (i < 6) {
          // Upper section: some scored, some not
          categories.add(ScoreCategory(index: i, score: i * 5));
        } else if (i < 12) {
          // Lower section: all scored
          categories.add(ScoreCategory(index: i, score: (i - 6) * 10 + 20));
        } else {
          // Bonus: not scored yet
          categories.add(ScoreCategory(index: i, score: null));
        }
      }

      final gameState = GameState(scoreCategories: categories);
      final jsonString = jsonEncode(gameState.toJson());

      when(
        mockSharedPreferences.setString(_gameStateKey, jsonString),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.getString(_gameStateKey),
      ).thenReturn(jsonString);

      await gameStateRepository.saveGameState(gameState);
      final loadedState = await gameStateRepository.loadGameState();

      expect(loadedState, isNotNull);
      expect(loadedState!.scoreCategories.length, 13);

      // Verify upper section
      for (int i = 0; i < 6; i++) {
        expect(loadedState.scoreCategories[i].score, i * 5);
      }

      // Verify lower section
      for (int i = 6; i < 12; i++) {
        expect(loadedState.scoreCategories[i].score, (i - 6) * 10 + 20);
      }

      // Verify bonus category
      expect(loadedState.scoreCategories[12].score, isNull);
    });
  });
}
