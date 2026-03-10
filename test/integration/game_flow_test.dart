import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/features/game/providers/game_provider.dart';
import 'package:poker_dice/core/constants/dice_faces.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('Full turn flow tests', () {
    test(
      'complete turn: roll 1 → hold dice → roll 2 → hold dice → roll 3 → select score',
      () {
        // Activate turn by scoring first category
        container.read(gameProvider.notifier).selectScore(0, 10);

        var state = container.read(gameProvider);
        expect(state.rollsRemaining, MAX_ROLLS);
        expect(state.isTurnActive, true);

        // Roll 1
        container.read(gameProvider.notifier).rollDice();
        state = container.read(gameProvider);
        expect(state.rollsRemaining, MAX_ROLLS - 1);
        expect(state.isTurnActive, true);

        // Hold some dice
        container.read(gameProvider.notifier).toggleHold(0);
        container.read(gameProvider.notifier).toggleHold(2);

        // Roll 2
        container.read(gameProvider.notifier).rollDice();
        state = container.read(gameProvider);
        expect(state.rollsRemaining, MAX_ROLLS - 2);
        expect(state.isTurnActive, true);
        expect(state.dice[0].isHeld, true);
        expect(state.dice[2].isHeld, true);

        // Hold additional dice
        container.read(gameProvider.notifier).toggleHold(4);

        // Roll 3 - rolls reach 0 but turn stays active
        container.read(gameProvider.notifier).rollDice();
        state = container.read(gameProvider);
        expect(state.rollsRemaining, 0);
        expect(state.isTurnActive, true);

        // Select score - should advance turn and reset rolls
        container.read(gameProvider.notifier).selectScore(1, 15);
        state = container.read(gameProvider);
        expect(state.rollsRemaining, MAX_ROLLS);
        expect(state.isTurnActive, true);
        expect(state.turnNumber, 3);
      },
    );

    test('dice are reset for new turn after score selection', () {
      // Activate turn and roll dice
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();

      // Hold all dice
      for (int i = 0; i < NUM_DICE; i++) {
        container.read(gameProvider.notifier).toggleHold(i);
      }

      // Roll to exhaust rolls (turn stays active)
      container.read(gameProvider.notifier).rollDice();

      final stateAfterRolls = container.read(gameProvider);
      expect(stateAfterRolls.rollsRemaining, 0);
      expect(stateAfterRolls.isTurnActive, true);

      // Select score to end turn and reset dice
      container.read(gameProvider.notifier).selectScore(1, 15);

      final stateAfterScore = container.read(gameProvider);
      expect(stateAfterScore.rollsRemaining, MAX_ROLLS);
      expect(stateAfterScore.isTurnActive, true);

      // Verify dice are fresh (not held)
      for (int i = 0; i < NUM_DICE; i++) {
        expect(stateAfterScore.dice[i].isHeld, false);
      }
    });
  });

  group('Game over detection tests', () {
    test('filling the 13th category triggers game over', () {
      // Score 12 categories (leaving 2 remaining)
      for (int i = 0; i < 12; i++) {
        container.read(gameProvider.notifier).selectScore(i, i * 5);
      }

      var state = container.read(gameProvider);
      expect(state.isGameOver, false);
      expect(state.categoriesRemaining(), 2);

      // Score the 13th category - this triggers game over (categoriesRemaining <= 1)
      container.read(gameProvider.notifier).selectScore(12, 55);

      state = container.read(gameProvider);
      expect(state.isGameOver, true);
    });

    test('isGameOver becomes true when 13 categories are filled', () {
      // Score 12 categories
      for (int i = 0; i < 12; i++) {
        container.read(gameProvider.notifier).selectScore(i, i * 5);
      }

      expect(container.read(gameProvider).isGameOver, false);

      // Fill the 13th category - triggers game over
      container.read(gameProvider.notifier).selectScore(12, 50);

      expect(container.read(gameProvider).isGameOver, true);
    });

    test('no more turns can be played after game over', () {
      // Score NUM_CATEGORIES categories to trigger game over
      for (int i = 0; i < NUM_CATEGORIES; i++) {
        container.read(gameProvider.notifier).selectScore(i, i * 5);
      }

      expect(container.read(gameProvider).isGameOver, true);

      // Try to play another turn
      container.read(gameProvider.notifier).rollDice();

      final state = container.read(gameProvider);
      expect(state.isGameOver, true);
      expect(state.rollsRemaining, MAX_ROLLS);
      expect(state.turnNumber, 13);
    });
  });

  group('Integration with Riverpod', () {
    test('state changes propagate correctly across multiple turns', () {
      // Turn 1
      container.read(gameProvider.notifier).selectScore(0, 10);
      var state = container.read(gameProvider);
      expect(state.turnNumber, 2);
      expect(state.scoreCategories[0].score, 10);
      expect(state.isCategoryScored(0), true);

      // Turn 2
      container.read(gameProvider.notifier).selectScore(1, 15);
      state = container.read(gameProvider);
      expect(state.turnNumber, 3);
      expect(state.scoreCategories[1].score, 15);
      expect(state.isCategoryScored(1), true);
      expect(state.isCategoryScored(0), true);

      // Turn 3
      container.read(gameProvider.notifier).selectScore(2, 20);
      state = container.read(gameProvider);
      expect(state.turnNumber, 4);
      expect(state.scoreCategories[2].score, 20);
    });

    test('multiple turns in sequence maintain correct state', () {
      // Play 5 full turns
      for (int i = 0; i < 5; i++) {
        container.read(gameProvider.notifier).selectScore(i, i * 10);

        final state = container.read(gameProvider);
        expect(state.turnNumber, i + 2);
        expect(state.scoreCategories[i].score, i * 10);
        expect(state.isCategoryScored(i), true);
      }

      // Verify all scored categories are still scored
      final state = container.read(gameProvider);
      for (int i = 0; i < 5; i++) {
        expect(state.scoreCategories[i].score, i * 10);
      }
    });

    test('ProviderContainer correctly tracks state across operations', () {
      // Initial state
      var state = container.read(gameProvider);
      expect(state.turnNumber, 1);
      expect(state.rollsRemaining, MAX_ROLLS);

      // First roll
      container.read(gameProvider.notifier).selectScore(0, 10);
      state = container.read(gameProvider);
      expect(state.turnNumber, 2);

      // Roll dice
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, 2);

      // Hold and roll again
      container.read(gameProvider.notifier).toggleHold(0);
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, 1);
      expect(state.dice[0].isHeld, true);

      // Final roll - rolls reach 0 but turn stays active
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, 0);
      expect(state.isTurnActive, true);
    });
  });
}
