import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/features/game/providers/game_provider.dart';
import 'package:poker_dice/features/game/providers/game_provider.dart'
    show gameProvider;
import 'package:poker_dice/core/constants/dice_faces.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('Game state transitions tests', () {
    test('initial game state has 5 dice', () {
      final state = container.read(gameProvider);
      expect(state.dice.length, NUM_DICE);
    });

    test('initial game state has 3 rolls remaining', () {
      final state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS);
    });

    test('initial game state has turn inactive (waits for first roll)', () {
      final state = container.read(gameProvider);
      expect(state.isTurnActive, false);
    });

    test('initial game state has no categories scored', () {
      final state = container.read(gameProvider);
      for (int i = 0; i < NUM_CATEGORIES; i++) {
        expect(state.isCategoryScored(i), false);
      }
    });

    test('initial game state has isGameOver false', () {
      final state = container.read(gameProvider);
      expect(state.isGameOver, false);
    });

    test('initial game state has turn number 1', () {
      final state = container.read(gameProvider);
      expect(state.turnNumber, 1);
    });
  });

  group('Roll mechanics tests', () {
    test('rollDice() decrements rollsRemaining', () {
      final state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS);

      // First roll does nothing because turn is not active
      container.read(gameProvider.notifier).rollDice();
      expect(container.read(gameProvider).rollsRemaining, MAX_ROLLS);

      // Activate the turn by setting isTurnActive (simulate UI starting turn)
      // Then subsequent rolls decrement rollsRemaining
      // Since we can't directly set isTurnActive, we test that after the turn
      // is active (via _endTurn after scoring), rolls decrement properly
      container.read(gameProvider.notifier).selectScore(0, 10);

      final updatedState = container.read(gameProvider);
      expect(updatedState.rollsRemaining, MAX_ROLLS);
      expect(updatedState.turnNumber, 2);

      // Now roll and check decrement
      container.read(gameProvider.notifier).rollDice();
      final afterRoll = container.read(gameProvider);
      expect(afterRoll.rollsRemaining, MAX_ROLLS - 1);
    });

    test('rollDice() only rolls non-held dice', () {
      // First roll to get some dice values
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();

      // Hold the first dice
      container.read(gameProvider.notifier).toggleHold(0);

      final stateBefore = container.read(gameProvider);
      final heldDiceValue = stateBefore.dice[0].value;

      // Roll again
      container.read(gameProvider.notifier).rollDice();

      final stateAfter = container.read(gameProvider);

      // Held dice should retain its value
      expect(stateAfter.dice[0].value, heldDiceValue);
      expect(stateAfter.dice[0].isHeld, true);
    });

    test('held dice retain their values across multiple rolls', () {
      // Roll twice to get dice values
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();

      // Hold dice at indices 0, 2, and 4
      container.read(gameProvider.notifier).toggleHold(0);
      container.read(gameProvider.notifier).toggleHold(2);
      container.read(gameProvider.notifier).toggleHold(4);

      final stateBefore = container.read(gameProvider);
      final heldValues = [
        stateBefore.dice[0].value,
        stateBefore.dice[2].value,
        stateBefore.dice[4].value,
      ];

      // Roll again
      container.read(gameProvider.notifier).rollDice();

      final stateAfter = container.read(gameProvider);

      // Held dice should retain values
      expect(stateAfter.dice[0].value, heldValues[0]);
      expect(stateAfter.dice[2].value, heldValues[1]);
      expect(stateAfter.dice[4].value, heldValues[2]);
    });

    test('auto-end turn when rolls reach 0', () {
      // Activate turn by scoring a category
      container.read(gameProvider.notifier).selectScore(0, 10);

      // Roll 2 times (rolls: 3→2→1)
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();

      final stateAfterTwoRolls = container.read(gameProvider);
      expect(stateAfterTwoRolls.rollsRemaining, 1);
      expect(stateAfterTwoRolls.isTurnActive, true);

      // Roll one more time to exhaust rolls (rolls: 1→0)
      // This triggers auto-end turn which calls _endTurn()
      container.read(gameProvider.notifier).rollDice();

      final state = container.read(gameProvider);

      // After _endTurn, rolls are reset to MAX_ROLLS and turn is active
      expect(state.rollsRemaining, MAX_ROLLS);
      expect(state.isTurnActive, true);
      expect(state.dice.length, NUM_DICE);
    });

    test('rollDice() does nothing when turn is not active', () {
      // Exhaust all rolls
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();

      final stateBefore = container.read(gameProvider);
      final rollsBefore = stateBefore.rollsRemaining;

      // Try to roll again
      container.read(gameProvider.notifier).rollDice();

      final stateAfter = container.read(gameProvider);

      expect(stateAfter.rollsRemaining, rollsBefore);
      expect(stateAfter.isTurnActive, false);
    });
  });

  group('Score selection tests', () {
    test('selectScore() fills category with score', () {
      const categoryIndex = 0;
      const score = 18;

      container.read(gameProvider.notifier).selectScore(categoryIndex, score);

      final state = container.read(gameProvider);
      expect(state.isCategoryScored(categoryIndex), true);
      expect(state.scoreCategories[categoryIndex].score, score);
    });

    test('selectScore() advances turn', () {
      final turnBefore = container.read(gameProvider).turnNumber;

      container.read(gameProvider.notifier).selectScore(0, 10);

      final turnAfter = container.read(gameProvider).turnNumber;

      expect(turnAfter, turnBefore + 1);
    });

    test('selectScore() can score 0', () {
      container.read(gameProvider.notifier).selectScore(0, 0);

      final state = container.read(gameProvider);
      expect(state.isCategoryScored(0), true);
      expect(state.scoreCategories[0].score, 0);
    });

    test('selectScore() advances turn number', () {
      container.read(gameProvider.notifier).selectScore(0, 10);
      final state1 = container.read(gameProvider);
      expect(state1.turnNumber, 2);

      container.read(gameProvider.notifier).selectScore(1, 10);
      final state2 = container.read(gameProvider);
      expect(state2.turnNumber, 3);
    });

    test('game over when all 13 categories filled', () {
      // Score all 13 categories
      for (int i = 0; i < NUM_CATEGORIES; i++) {
        container.read(gameProvider.notifier).selectScore(i, i * 5);
      }

      final state = container.read(gameProvider);

      expect(state.isGameOver, true);
      expect(state.isTurnActive, false);
    });

    test('selectScore() with invalid index does nothing', () {
      container.read(gameProvider.notifier).selectScore(-1, 10);
      container.read(gameProvider.notifier).selectScore(13, 10);

      final state = container.read(gameProvider);
      for (int i = 0; i < NUM_CATEGORIES; i++) {
        expect(state.isCategoryScored(i), false);
      }
    });

    test('selectScore() on already scored category does nothing', () {
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).selectScore(0, 20);

      final state = container.read(gameProvider);
      expect(state.scoreCategories[0].score, 10);
    });
  });

  group('Reset game tests', () {
    test('resetGame() creates fresh state', () {
      // Modify state
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).selectScore(1, 20);
      container.read(gameProvider.notifier).rollDice();

      container.read(gameProvider.notifier).resetGame();

      final state = container.read(gameProvider);

      expect(state.dice.length, NUM_DICE);
      expect(state.rollsRemaining, MAX_ROLLS);
      expect(state.isTurnActive, false);
      expect(state.isGameOver, false);
    });

    test('resetGame() resets all categories', () {
      // Score some categories
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).selectScore(5, 20);
      container.read(gameProvider.notifier).selectScore(12, 30);

      container.read(gameProvider.notifier).resetGame();

      final state = container.read(gameProvider);

      for (int i = 0; i < NUM_CATEGORIES; i++) {
        expect(state.isCategoryScored(i), false);
      }
    });

    test('resetGame() resets turn number to 1', () {
      // Advance turn by scoring
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).selectScore(1, 10);
      container.read(gameProvider.notifier).selectScore(2, 10);

      container.read(gameProvider.notifier).resetGame();

      final state = container.read(gameProvider);
      expect(state.turnNumber, 1);
    });

    test('resetGame() allows new game to be played', () {
      // Score all categories to end game
      for (int i = 0; i < NUM_CATEGORIES; i++) {
        container.read(gameProvider.notifier).selectScore(i, i * 5);
      }

      expect(container.read(gameProvider).isGameOver, true);

      // Reset game
      container.read(gameProvider.notifier).resetGame();

      final state = container.read(gameProvider);

      expect(state.isGameOver, false);
      expect(state.isTurnActive, false);
      expect(state.rollsRemaining, MAX_ROLLS);
    });
  });
}
