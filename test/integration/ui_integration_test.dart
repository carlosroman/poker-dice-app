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

  group('Dice selection updates potential scores tests', () {
    test('holding dice recalculates potential scores', () {
      // Activate turn
      container.read(gameProvider.notifier).selectScore(0, 10);

      // Roll first time
      container.read(gameProvider.notifier).rollDice();
      final stateAfterRoll1 = container.read(gameProvider);
      final diceValuesBeforeHold = stateAfterRoll1.dice
          .map((d) => d.value!)
          .toList();
      final potentialScoresBeforeHold = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValuesBeforeHold);

      // Hold first die
      container.read(gameProvider.notifier).toggleHold(0);
      container.read(gameProvider);

      // Roll second time
      container.read(gameProvider.notifier).rollDice();
      final stateAfterRoll2 = container.read(gameProvider);
      final diceValuesAfterRoll = stateAfterRoll2.dice
          .map((d) => d.value!)
          .toList();
      final potentialScoresAfterRoll = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValuesAfterRoll);

      // Verify held die didn't change
      expect(stateAfterRoll2.dice[0].isHeld, true);
      expect(stateAfterRoll2.dice[0].value, stateAfterRoll1.dice[0].value);

      // Verify potential scores were recalculated based on new dice values
      expect(potentialScoresAfterRoll.length, NUM_CATEGORIES);
      expect(
        potentialScoresAfterRoll,
        isNot(equals(potentialScoresBeforeHold)),
      );
    });

    test('potential scores change when dice values change', () {
      // Activate turn
      container.read(gameProvider.notifier).selectScore(0, 10);

      // Roll first time
      container.read(gameProvider.notifier).rollDice();
      final state1 = container.read(gameProvider);
      final diceValues1 = state1.dice.map((d) => d.value!).toList();
      final scores1 = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues1);

      // Roll second time (without holding)
      container.read(gameProvider.notifier).rollDice();
      final state2 = container.read(gameProvider);
      final diceValues2 = state2.dice.map((d) => d.value!).toList();
      final scores2 = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues2);

      // Verify dice values changed
      expect(diceValues1, isNot(equals(diceValues2)));

      // Verify potential scores changed
      expect(scores2, isNot(equals(scores1)));
    });

    test('scored categories show actual scores, not potential', () {
      // Activate turn
      container.read(gameProvider.notifier).selectScore(0, 10);

      // Roll dice
      container.read(gameProvider.notifier).rollDice();

      // Select a score for Pair of 10s (category 1)
      final diceValues = container
          .read(gameProvider)
          .dice
          .map((d) => d.value!)
          .toList();
      final potentialScore = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues)[1];

      container.read(gameProvider.notifier).selectScore(1, potentialScore);

      final state = container.read(gameProvider);

      // Verify category is scored
      expect(state.isCategoryScored(1), true);
      expect(state.scoreCategories[1].score, potentialScore);

      // Verify the score is the actual score, not null (potential)
      expect(state.scoreCategories[1].score, isNotNull);
      expect(state.scoreCategories[1].score, potentialScore);
    });
  });

  group('UI state synchronization tests', () {
    test('roll button state syncs with rolls remaining', () {
      // Initial state - turn active, rolls at MAX
      var state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS);
      expect(state.isTurnActive, true);

      // After first roll - 2 rolls remaining
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS - 1);
      expect(state.isTurnActive, true);

      // After second roll - 1 roll remaining
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS - 2);
      expect(state.isTurnActive, true);

      // After third roll - 0 rolls remaining, turn ends, resets to MAX
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS);
      expect(state.isTurnActive, true);
    });

    test('score sheet state syncs with game state', () {
      // Activate turn
      container.read(gameProvider.notifier).selectScore(0, 10);

      // Roll dice
      container.read(gameProvider.notifier).rollDice();

      // Get potential score and select it
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

      // Verify score category is marked as scored
      expect(state.isCategoryScored(1), true);
      expect(state.scoreCategories[1].score, score);

      // Verify turn advanced
      expect(state.turnNumber, 3);

      // Score another category
      container.read(gameProvider.notifier).rollDice();
      final diceValues2 = container
          .read(gameProvider)
          .dice
          .map((d) => d.value!)
          .toList();
      final score2 = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues2)[2];

      container.read(gameProvider.notifier).selectScore(2, score2);

      final state2 = container.read(gameProvider);
      expect(state2.isCategoryScored(1), true);
      expect(state2.isCategoryScored(2), true);
      expect(state2.turnNumber, 4);
    });

    test('dice hold state syncs with model', () {
      // Activate turn
      container.read(gameProvider.notifier).selectScore(0, 10);

      // Roll dice
      container.read(gameProvider.notifier).rollDice();

      // Verify initial hold state
      var state = container.read(gameProvider);
      for (int i = 0; i < NUM_DICE; i++) {
        expect(state.dice[i].isHeld, false);
      }

      // Hold some dice
      container.read(gameProvider.notifier).toggleHold(0);
      container.read(gameProvider.notifier).toggleHold(2);
      container.read(gameProvider.notifier).toggleHold(4);

      state = container.read(gameProvider);
      expect(state.dice[0].isHeld, true);
      expect(state.dice[1].isHeld, false);
      expect(state.dice[2].isHeld, true);
      expect(state.dice[3].isHeld, false);
      expect(state.dice[4].isHeld, true);

      // Roll - held dice should maintain their state
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.dice[0].isHeld, true);
      expect(state.dice[2].isHeld, true);
      expect(state.dice[4].isHeld, true);

      // Unhold dice
      container.read(gameProvider.notifier).toggleHold(0);
      container.read(gameProvider.notifier).toggleHold(4);

      state = container.read(gameProvider);
      expect(state.dice[0].isHeld, false);
      expect(state.dice[4].isHeld, false);
      expect(state.dice[2].isHeld, true);
    });
  });

  group('Full UI flow tests', () {
    test('complete turn: roll → hold → roll → select score', () {
      // Start turn
      container.read(gameProvider.notifier).selectScore(0, 10);
      var state = container.read(gameProvider);
      expect(state.isTurnActive, true);
      expect(state.rollsRemaining, MAX_ROLLS);

      // Roll 1
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS - 1);
      expect(state.isTurnActive, true);

      // Hold dice
      container.read(gameProvider.notifier).toggleHold(0);
      container.read(gameProvider.notifier).toggleHold(1);

      state = container.read(gameProvider);
      expect(state.dice[0].isHeld, true);
      expect(state.dice[1].isHeld, true);

      // Roll 2
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS - 2);
      expect(state.dice[0].isHeld, true);
      expect(state.dice[1].isHeld, true);

      // Select score
      final diceValues = state.dice.map((d) => d.value!).toList();
      final score = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues)[3];

      container.read(gameProvider.notifier).selectScore(3, score);

      state = container.read(gameProvider);
      expect(state.isCategoryScored(3), true);
      expect(state.scoreCategories[3].score, score);
      expect(state.turnNumber, 3);
      expect(state.rollsRemaining, MAX_ROLLS);
    });

    test('UI updates correctly at each step', () {
      // Initial state - turn already active
      var state = container.read(gameProvider);
      expect(state.turnNumber, 1);
      expect(state.rollsRemaining, MAX_ROLLS);
      expect(state.isTurnActive, true);

      // Roll 1 - UI should show 2 rolls remaining
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.turnNumber, 1);
      expect(state.rollsRemaining, MAX_ROLLS - 1);
      expect(state.isTurnActive, true);

      // Roll 2 - UI should show 1 roll remaining
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, 1);
      expect(state.isTurnActive, true);

      // Hold dice - UI should show held dice
      container.read(gameProvider.notifier).toggleHold(0);
      container.read(gameProvider.notifier).toggleHold(2);
      state = container.read(gameProvider);
      expect(state.dice[0].isHeld, true);
      expect(state.dice[2].isHeld, true);

      // Roll 3 - exhausts rolls, turn auto-ends, resets to MAX
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS);
      expect(state.isTurnActive, true);

      // Roll again for new turn
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS - 1);
      expect(state.isTurnActive, true);

      // Select score - UI should show category scored and turn advance
      final diceValues = state.dice.map((d) => d.value!).toList();
      final score = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues)[4];

      container.read(gameProvider.notifier).selectScore(4, score);
      state = container.read(gameProvider);
      expect(state.isCategoryScored(4), true);
      expect(state.turnNumber, 3);
    });

    test('multiple turns maintain correct UI state', () {
      // Turn 1
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).rollDice();
      final diceValues1 = container
          .read(gameProvider)
          .dice
          .map((d) => d.value!)
          .toList();
      final score1 = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues1)[0];
      container.read(gameProvider.notifier).selectScore(0, score1);

      var state = container.read(gameProvider);
      expect(state.turnNumber, 2);
      expect(state.isCategoryScored(0), true);

      // Turn 2
      container.read(gameProvider.notifier).rollDice();
      final diceValues2 = container
          .read(gameProvider)
          .dice
          .map((d) => d.value!)
          .toList();
      final score2 = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues2)[1];
      container.read(gameProvider.notifier).selectScore(1, score2);

      state = container.read(gameProvider);
      expect(state.turnNumber, 3);
      expect(state.isCategoryScored(0), true);
      expect(state.isCategoryScored(1), true);

      // Turn 3
      container.read(gameProvider.notifier).rollDice();
      final diceValues3 = container
          .read(gameProvider)
          .dice
          .map((d) => d.value!)
          .toList();
      final score3 = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues3)[2];
      container.read(gameProvider.notifier).selectScore(2, score3);

      state = container.read(gameProvider);
      expect(state.turnNumber, 4);
      expect(state.isCategoryScored(0), true);
      expect(state.isCategoryScored(1), true);
      expect(state.isCategoryScored(2), true);
    });
  });

  group('Edge cases', () {
    test('holding all dice and rolling maintains hold state', () {
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).rollDice();

      // Hold all dice
      for (int i = 0; i < NUM_DICE; i++) {
        container.read(gameProvider.notifier).toggleHold(i);
      }

      var state = container.read(gameProvider);
      for (int i = 0; i < NUM_DICE; i++) {
        expect(state.dice[i].isHeld, true);
      }

      // Roll - all dice should remain held
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      for (int i = 0; i < NUM_DICE; i++) {
        expect(state.dice[i].isHeld, true);
      }
    });

    test('potential scores are calculated correctly after holding', () {
      container.read(gameProvider.notifier).selectScore(0, 10);
      container.read(gameProvider.notifier).rollDice();

      final state1 = container.read(gameProvider);
      final diceValues1 = state1.dice.map((d) => d.value!).toList();
      container.read(gameProvider.notifier).getPotentialScores(diceValues1);

      // Hold first die
      container.read(gameProvider.notifier).toggleHold(0);
      container.read(gameProvider.notifier).rollDice();

      final state2 = container.read(gameProvider);
      final diceValues2 = state2.dice.map((d) => d.value!).toList();
      final scores2 = container
          .read(gameProvider.notifier)
          .getPotentialScores(diceValues2);

      // Verify first die didn't change
      expect(state2.dice[0].value, state1.dice[0].value);

      // Verify scores were recalculated
      expect(scores2.length, NUM_CATEGORIES);
    });
  });
}
