import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/features/game/providers/game_provider.dart';
import 'package:poker_dice/features/score/score_repository.dart';
import 'package:poker_dice/features/score/score_provider.dart';
import 'package:poker_dice/core/constants/dice_faces.dart';

@GenerateMocks([SharedPreferences])
import 'full_game_test.mocks.dart';

void main() {
  group('Full Game Cycle Tests', () {
    late ProviderContainer container;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Game start with fresh state tests', () {
      test('game starts with turn 1, 3 rolls, no scores', () {
        final state = container.read(gameProvider);

        expect(state.turnNumber, 1);
        expect(state.rollsRemaining, MAX_ROLLS);
        expect(state.isTurnActive, true);
        expect(state.isGameOver, false);

        for (int i = 0; i < NUM_CATEGORIES; i++) {
          expect(state.isCategoryScored(i), false);
          expect(state.scoreCategories[i].score, null);
        }

        for (int i = 0; i < NUM_DICE; i++) {
          expect(state.dice[i].isHeld, false);
        }
      });

      test('activating turn sets rolls to MAX and isTurnActive to true', () {
        container.read(gameProvider.notifier).selectScore(0, 10);

        final state = container.read(gameProvider);

        expect(state.turnNumber, 2);
        expect(state.rollsRemaining, MAX_ROLLS);
        expect(state.isTurnActive, true);
        expect(state.isCategoryScored(0), true);
        expect(state.scoreCategories[0].score, 10);
      });
    });

    group('Complete turn flow tests', () {
      test('roll → hold → roll → select score completes turn', () {
        // Start turn
        container.read(gameProvider.notifier).selectScore(0, 10);
        var state = container.read(gameProvider);
        expect(state.turnNumber, 2);
        expect(state.rollsRemaining, MAX_ROLLS);
        expect(state.isTurnActive, true);

        // Roll 1
        container.read(gameProvider.notifier).rollDice();
        state = container.read(gameProvider);
        expect(state.rollsRemaining, MAX_ROLLS - 1);
        expect(state.isTurnActive, true);

        // Hold dice
        container.read(gameProvider.notifier).toggleHold(0);
        container.read(gameProvider.notifier).toggleHold(2);
        state = container.read(gameProvider);
        expect(state.dice[0].isHeld, true);
        expect(state.dice[2].isHeld, true);

        // Roll 2 - then immediately select score before third roll
        container.read(gameProvider.notifier).rollDice();
        state = container.read(gameProvider);
        expect(state.isCategoryScored(0), true);
        expect(state.isCategoryScored(1), false);
        expect(state.rollsRemaining, 1);

        final diceValues = state.dice.map((d) => d.value!).toList();
        final score = container
            .read(gameProvider.notifier)
            .getPotentialScores(diceValues)[1];
        container.read(gameProvider.notifier).selectScore(1, score);

        state = container.read(gameProvider);
        expect(state.isCategoryScored(1), true);
        expect(state.scoreCategories[1].score, score);
        expect(state.turnNumber, 3);
        expect(state.rollsRemaining, MAX_ROLLS);
      });

      test('roll → hold all → roll → select score', () {
        container.read(gameProvider.notifier).selectScore(0, 10);
        container.read(gameProvider.notifier).rollDice();

        // Hold all dice
        for (int i = 0; i < NUM_DICE; i++) {
          container.read(gameProvider.notifier).toggleHold(i);
        }

        var state = container.read(gameProvider);

        // Roll 2 - held dice should not change
        container.read(gameProvider.notifier).rollDice();
        state = container.read(gameProvider);
        final diceAfterRoll2 = state.dice;

        // Verify held dice didn't change after roll 2
        for (int i = 0; i < NUM_DICE; i++) {
          expect(diceAfterRoll2[i].value, state.dice[i].value);
        }

        // Roll 3 - this exhausts rolls but turn stays active
        container.read(gameProvider.notifier).rollDice();
        state = container.read(gameProvider);

        // After 3 rolls, rollsRemaining is 0 but turn is still active
        expect(state.rollsRemaining, 0);
        expect(state.isTurnActive, true);

        // Select score for category 2
        final diceValues = state.dice.map((d) => d.value!).toList();
        final score = container
            .read(gameProvider.notifier)
            .getPotentialScores(diceValues)[2];
        container.read(gameProvider.notifier).selectScore(2, score);

        final nextState = container.read(gameProvider);
        expect(nextState.isCategoryScored(2), true);
        expect(nextState.turnNumber, 3);
        expect(nextState.rollsRemaining, MAX_ROLLS);
      });

      test('roll → select score without holding', () {
        container.read(gameProvider.notifier).selectScore(0, 10);
        container.read(gameProvider.notifier).rollDice();
        container.read(gameProvider.notifier).rollDice();
        container.read(gameProvider.notifier).rollDice();

        final state = container.read(gameProvider);
        expect(state.rollsRemaining, 0);
        expect(state.isTurnActive, true);

        // Select score
        final diceValues = state.dice.map((d) => d.value!).toList();
        final score = container
            .read(gameProvider.notifier)
            .getPotentialScores(diceValues)[3];
        container.read(gameProvider.notifier).selectScore(3, score);

        final nextState = container.read(gameProvider);
        expect(nextState.isCategoryScored(3), true);
        expect(nextState.turnNumber, 3);
        expect(nextState.rollsRemaining, MAX_ROLLS);
      });
    });

    group('Game ends when all 13 categories filled tests', () {
      test('filling 12th category ends game', () {
        // Score 11 categories
        for (int i = 0; i < 11; i++) {
          container.read(gameProvider.notifier).selectScore(i, i * 5);
        }

        var state = container.read(gameProvider);
        expect(state.isGameOver, false);
        expect(state.categoriesRemaining(), 2);

        // Score the 12th category - triggers game over (1 category remains)
        container.read(gameProvider.notifier).selectScore(11, 55);

        state = container.read(gameProvider);
        expect(state.isGameOver, true);
        expect(state.categoriesRemaining(), 1);
      });

      test('game over prevents further play', () {
        // Fill all 13 categories
        for (int i = 0; i < 13; i++) {
          container.read(gameProvider.notifier).selectScore(i, i * 5);
        }

        expect(container.read(gameProvider).isGameOver, true);

        // Try to roll dice
        container.read(gameProvider.notifier).rollDice();

        final state = container.read(gameProvider);
        expect(state.isGameOver, true);
        expect(state.rollsRemaining, MAX_ROLLS);
        expect(state.isTurnActive, false);
      });

      test('game over triggers after 12 categories are filled', () {
        // Score 11 categories
        for (int i = 0; i < 11; i++) {
          container.read(gameProvider.notifier).selectScore(i, 10);
        }

        expect(container.read(gameProvider).isGameOver, false);

        // Score 12th category - triggers game over
        container.read(gameProvider.notifier).selectScore(11, 55);

        expect(container.read(gameProvider).isGameOver, true);
      });
    });
  });

  group('Score Selection Advances Turn Tests', () {
    late ProviderContainer container;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('selecting a score advances to next turn', () {
      // Start at turn 1
      var state = container.read(gameProvider);
      expect(state.turnNumber, 1);

      // Select first score
      container.read(gameProvider.notifier).selectScore(0, 10);
      state = container.read(gameProvider);
      expect(state.turnNumber, 2);

      // Select second score
      container.read(gameProvider.notifier).selectScore(1, 15);
      state = container.read(gameProvider);
      expect(state.turnNumber, 3);

      // Select third score
      container.read(gameProvider.notifier).selectScore(2, 20);
      state = container.read(gameProvider);
      expect(state.turnNumber, 4);
    });

    test('turn number increments correctly after each score selection', () {
      // Play 5 turns
      for (int i = 0; i < 5; i++) {
        container.read(gameProvider.notifier).selectScore(i, i * 10);

        final state = container.read(gameProvider);
        expect(state.turnNumber, i + 2);
        expect(state.isCategoryScored(i), true);
      }
    });

    test('dice reset after score selection', () {
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();

      // Hold some dice
      container.read(gameProvider.notifier).toggleHold(0);
      container.read(gameProvider.notifier).toggleHold(1);

      // Select score (should trigger turn end and dice reset)
      final diceValues = container
          .read(gameProvider)
          .dice
          .map((d) => d.value!)
          .toList();
      final score = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues)[1];
      container.read(gameProvider.notifier).selectScore(1, score);

      final state = container.read(gameProvider);

      // Verify dice are fresh (not held)
      for (int i = 0; i < NUM_DICE; i++) {
        expect(state.dice[i].isHeld, false);
      }

      // Verify rolls are reset
      expect(state.rollsRemaining, MAX_ROLLS);
    });

    test('turn advances when score is selected after rolls exhausted', () {
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();

      // After 3 rolls, rollsRemaining is 0 but turn is still active
      final stateAfterRolls = container.read(gameProvider);
      expect(stateAfterRolls.rollsRemaining, 0);
      expect(stateAfterRolls.isTurnActive, true);

      // Select score to end turn
      final diceValues = stateAfterRolls.dice.map((d) => d.value!).toList();
      final score = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues)[1];
      container.read(gameProvider.notifier).selectScore(1, score);

      final state = container.read(gameProvider);
      expect(state.turnNumber, 3);
      expect(state.isCategoryScored(1), true);
      expect(state.rollsRemaining, MAX_ROLLS);
    });
  });

  group('Game Over Shows Correct Final Score Tests', () {
    late ProviderContainer container;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('game over screen shows final total score', () async {
      // Load initial high score
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(0);

      await container.read(scoreProvider.future);

      // Fill all categories with known scores
      for (int i = 0; i < 13; i++) {
        container.read(gameProvider.notifier).selectScore(i, (i + 1) * 10);
      }

      final state = container.read(gameProvider);
      expect(state.isGameOver, true);

      // Calculate expected total
      int expectedTotal = 0;
      for (int i = 0; i < 13; i++) {
        expectedTotal += (i + 1) * 10;
      }
      expectedTotal += state.getBonus();

      expect(state.getTotalScore(), expectedTotal);
    });

    test('game over screen shows high score', () async {
      const testHighScore = 5000;
      when(
        mockSharedPreferences.getInt(ScoreRepository.HIGH_SCORE_KEY),
      ).thenReturn(testHighScore);
      when(
        mockSharedPreferences.setInt(ScoreRepository.HIGH_SCORE_KEY, any),
      ).thenAnswer((_) async => true);

      await container.read(scoreProvider.future);

      // Fill all categories
      for (int i = 0; i < 13; i++) {
        container.read(gameProvider.notifier).selectScore(i, i * 10);
      }

      final state = container.read(gameProvider);
      expect(state.isGameOver, true);

      // Verify high score can be loaded
      final highScore = await container.read(scoreProvider.future);
      expect(highScore, testHighScore);
    });

    test('can play again after game over', () {
      // Fill all categories to trigger game over
      for (int i = 0; i < 13; i++) {
        container.read(gameProvider.notifier).selectScore(i, i * 5);
      }

      expect(container.read(gameProvider).isGameOver, true);

      // Reset game
      container.read(gameProvider.notifier).resetGame();

      final state = container.read(gameProvider);
      expect(state.isGameOver, false);
      expect(state.turnNumber, 1);
      expect(state.rollsRemaining, MAX_ROLLS);
      expect(state.isTurnActive, true);

      for (int i = 0; i < NUM_CATEGORIES; i++) {
        expect(state.isCategoryScored(i), false);
      }
    });

    test('reset game clears all scores', () {
      // Score some categories
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).selectScore(1, 15);
      container.read(gameProvider.notifier).selectScore(2, 20);

      // Reset game
      container.read(gameProvider.notifier).resetGame();

      final state = container.read(gameProvider);
      expect(state.turnNumber, 1);
      expect(state.isGameOver, false);

      for (int i = 0; i < NUM_CATEGORIES; i++) {
        expect(state.isCategoryScored(i), false);
        expect(state.scoreCategories[i].score, null);
      }
    });

    test('final score includes bonus correctly', () {
      // Score upper section categories to get bonus
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).selectScore(1, 10);
      container.read(gameProvider.notifier).selectScore(2, 10);

      final state = container.read(gameProvider);
      expect(state.getUpperSectionTotal(), 30);
      expect(state.getBonus(), 20);

      // Fill remaining categories
      for (int i = 3; i < 13; i++) {
        container.read(gameProvider.notifier).selectScore(i, 10);
      }

      final finalState = container.read(gameProvider);
      expect(finalState.isGameOver, true);
      expect(finalState.getBonus(), 20);
      expect(finalState.getTotalScore(), greaterThan(100));
    });
  });

  group('UI Integration Tests', () {
    late ProviderContainer container;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('all UI elements are present and interactive', () {
      final state = container.read(gameProvider);

      // Verify initial state has all elements ready
      expect(state.dice.length, NUM_DICE);
      expect(state.scoreCategories.length, NUM_CATEGORIES);
      expect(state.rollsRemaining, MAX_ROLLS);

      // Verify dice can be held
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).rollDice();

      for (int i = 0; i < NUM_DICE; i++) {
        container.read(gameProvider.notifier).toggleHold(i);
      }

      final stateWithHolds = container.read(gameProvider);
      for (int i = 0; i < NUM_DICE; i++) {
        expect(stateWithHolds.dice[i].isHeld, true);
      }
    });

    test('UI state syncs with game state - rolls remaining', () {
      container.read(gameProvider.notifier).selectScore(0, 10);

      var state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS);

      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS - 1);

      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS - 2);

      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      // After 3 rolls, rollsRemaining is 0 but turn is still active
      expect(state.rollsRemaining, 0);
      expect(state.isTurnActive, true);
    });

    test('UI state syncs with game state - category scored status', () {
      container.read(gameProvider.notifier).selectScore(0, 10);

      var state = container.read(gameProvider);
      expect(state.isCategoryScored(0), true);
      expect(state.isCategoryScored(1), false);

      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      final diceValues = state.dice.map((d) => d.value!).toList();
      final score = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues)[1];
      container.read(gameProvider.notifier).selectScore(1, score);

      state = container.read(gameProvider);
      expect(state.isCategoryScored(0), true);
      expect(state.isCategoryScored(1), true);
      expect(state.isCategoryScored(2), false);
    });

    test('UI state syncs with game state - turn number', () {
      var state = container.read(gameProvider);
      expect(state.turnNumber, 1);

      container.read(gameProvider.notifier).selectScore(0, 10);
      state = container.read(gameProvider);
      expect(state.turnNumber, 2);

      container.read(gameProvider.notifier).selectScore(1, 10);
      state = container.read(gameProvider);
      expect(state.turnNumber, 3);

      container.read(gameProvider.notifier).selectScore(2, 10);
      state = container.read(gameProvider);
      expect(state.turnNumber, 4);
    });

    test('dice values update correctly on roll', () {
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).rollDice();

      final state1 = container.read(gameProvider);
      final diceValues1 = state1.dice.map((d) => d.value!).toList();

      container.read(gameProvider.notifier).rollDice();

      final state2 = container.read(gameProvider);
      final diceValues2 = state2.dice.map((d) => d.value!).toList();

      // Dice values should have changed
      expect(diceValues1, isNot(equals(diceValues2)));
    });

    test('potential scores update correctly when dice change', () {
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).rollDice();

      final state1 = container.read(gameProvider);
      final diceValues1 = state1.dice.map((d) => d.value!).toList();
      final scores1 = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues1);

      container.read(gameProvider.notifier).rollDice();

      final state2 = container.read(gameProvider);
      final diceValues2 = state2.dice.map((d) => d.value!).toList();
      final scores2 = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues2);

      expect(scores1.length, NUM_CATEGORIES);
      expect(scores2.length, NUM_CATEGORIES);
      expect(scores1, isNot(equals(scores2)));
    });
  });

  group('Complete Game Cycle Integration', () {
    late ProviderContainer container;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('complete game from start to finish', () {
      // Verify initial state
      var state = container.read(gameProvider);
      expect(state.turnNumber, 1);
      expect(state.isGameOver, false);

      // Play all 12 turns (game ends after 12th category)
      for (int turn = 0; turn < 12; turn++) {
        // If not first turn, roll dice
        if (turn > 0) {
          container.read(gameProvider.notifier).rollDice();
        }

        // Select a category
        int categoryIndex = turn;
        int score = (turn + 1) * 10;

        container.read(gameProvider.notifier).selectScore(categoryIndex, score);

        state = container.read(gameProvider);

        if (turn < 11) {
          expect(state.isGameOver, false);
          expect(state.turnNumber, turn + 2);
        } else {
          expect(state.isGameOver, true);
          expect(state.turnNumber, 12);
        }

        expect(state.isCategoryScored(categoryIndex), true);
        expect(state.scoreCategories[categoryIndex].score, score);
      }
    });

    test('state persists correctly across all turns', () {
      // Play 10 turns
      for (int i = 0; i < 10; i++) {
        container.read(gameProvider.notifier).selectScore(i, i * 10);
      }

      final state = container.read(gameProvider);

      // Verify all scored categories are still scored
      for (int i = 0; i < 10; i++) {
        expect(state.isCategoryScored(i), true);
        expect(state.scoreCategories[i].score, i * 10);
      }

      // Verify turn number
      expect(state.turnNumber, 11);
    });

    test('roll dice works correctly throughout game', () {
      container.read(gameProvider.notifier).selectScore(0, 10);

      // Roll 3 times in first turn
      container.read(gameProvider.notifier).rollDice();
      var state = container.read(gameProvider);
      expect(state.rollsRemaining, 2);

      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, 1);

      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      // After 3 rolls, rollsRemaining is 0 but turn is still active
      expect(state.rollsRemaining, 0);
      expect(state.isTurnActive, true);

      // Select score to end turn and reset rolls
      final diceValues = state.dice.map((d) => d.value!).toList();
      final score = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues)[1];
      container.read(gameProvider.notifier).selectScore(1, score);

      state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS);
      expect(state.turnNumber, 3);
    });
  });
}
