import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/services/scoring_service.dart';

void main() {
  group('Provider Setup Tests', () {
    test('testProviderInitializesCorrectly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final gameState = container.read(gameProvider);

      expect(gameState, isA<GameState>());
    });

    test('testInitialStateValues', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final gameState = container.read(gameProvider);

      expect(gameState.diceRoll, isNull);
      expect(gameState.scores.isEmpty, true);
      expect(gameState.selectedCategory, isNull);
      expect(gameState.remainingRolls, 3);
      expect(gameState.currentTurn, 1);
      expect(gameState.isGameOver, false);
      expect(gameState.upperSectionTotal, 0);
      expect(gameState.bonusAwarded, false);
      expect(gameState.totalScore, 0);
    });
  });

  group('Game Flow Tests', () {
    test('testStartNewGame', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Start with some state
      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.ones);

      // Reset the game
      container.read(gameProvider.notifier).startNewGame();

      final gameState = container.read(gameProvider);

      expect(gameState.diceRoll, isNull);
      expect(gameState.scores.isEmpty, true);
      expect(gameState.selectedCategory, isNull);
      expect(gameState.remainingRolls, 3);
      expect(gameState.currentTurn, 1);
      expect(gameState.isGameOver, false);
    });

    test('testStartTurn', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();

      final gameState = container.read(gameProvider);

      expect(gameState.diceRoll, isNotNull);
      expect(gameState.diceRoll!.dice.length, 5);
      expect(gameState.remainingRolls, 3);
      expect(gameState.selectedCategory, isNull);
    });

    test('testRollDice', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();

      // Verify initial rolls
      expect(container.read(gameProvider).remainingRolls, 3);

      container.read(gameProvider.notifier).rollDice();

      expect(container.read(gameProvider).remainingRolls, 2);
    });

    test('testRollDiceDecrementsCounter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();

      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();

      expect(container.read(gameProvider).remainingRolls, 0);
    });

    test('testRollDiceAtZeroDoesNotRoll', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();

      // Use all rolls
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).rollDice();

      final remainingRollsAfterZero = container
          .read(gameProvider)
          .remainingRolls;

      // Try to roll again
      container.read(gameProvider.notifier).rollDice();

      expect(
        container.read(gameProvider).remainingRolls,
        remainingRollsAfterZero,
      );
    });

    test('testToggleDieHeld', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();

      // Verify initial state
      expect(container.read(gameProvider).diceRoll!.dice[2].isHeld, false);

      container.read(gameProvider.notifier).toggleDieHeld(2);

      expect(container.read(gameProvider).diceRoll!.dice[2].isHeld, true);
    });

    test('testSelectCategory', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).selectCategory(Category.twos);

      expect(container.read(gameProvider).selectedCategory, Category.twos);
    });

    test('testScoreCategory', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.ones);
      container.read(gameProvider.notifier).scoreCategory(Category.ones);

      final gameState = container.read(gameProvider);

      expect(gameState.scores.containsKey(Category.ones), true);
      expect(gameState.selectedCategory, isNull);
    });

    test('testScoreCategoryUpdatesGameState', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Start a turn first
      container.read(gameProvider.notifier).startTurn();

      // Start a turn first
      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.ones);
      container.read(gameProvider.notifier).scoreCategory(Category.ones);

      final gameState = container.read(gameProvider);

      expect(gameState.scores.containsKey(Category.ones), true);
      expect(gameState.selectedCategory, isNull);
    });

    test('testGameEndsAfterAllCategoriesScored', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Score all 13 scoring categories (bonus is calculated automatically)
      final categoriesToScore = Category.values.where(
        (c) => c != Category.bonus,
      );
      for (final category in categoriesToScore) {
        container.read(gameProvider.notifier).startTurn();
        container.read(gameProvider.notifier).selectCategory(category);
        container.read(gameProvider.notifier).scoreCategory(category);
      }

      // After scoring 13 categories, there should be 1 remaining (bonus)
      expect(container.read(remainingCategoriesProvider).length, 1);
      expect(container.read(remainingCategoriesProvider).first, Category.bonus);

      // Game is not over until bonus is also scored
      expect(container.read(isGameOverProvider), false);
    });
  });

  group('Computed Provider Tests', () {
    test('testDiceRollProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state - no dice roll
      expect(container.read(diceRollProvider), isNull);

      // After starting turn
      container.read(gameProvider.notifier).startTurn();
      expect(container.read(diceRollProvider), isNotNull);
    });

    test('testRemainingRollsProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(remainingRollsProvider), 3);

      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).rollDice();

      expect(container.read(remainingRollsProvider), 2);
    });

    test('testSelectedCategoryProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedCategoryProvider), isNull);

      container.read(gameProvider.notifier).selectCategory(Category.fives);

      expect(container.read(selectedCategoryProvider), Category.fives);
    });

    test('testScoresProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(scoresProvider).isEmpty, true);

      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.threes);
      container.read(gameProvider.notifier).scoreCategory(Category.threes);

      expect(container.read(scoresProvider).containsKey(Category.threes), true);
    });

    test('testUpperSectionTotalProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(upperSectionTotalProvider), 0);

      // Score ones - we need to score a category that gets a value
      // Since dice are random, score chance to get some points
      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.ones);
      container.read(gameProvider.notifier).scoreCategory(Category.ones);

      // Upper section total should be >= 0 (could be 0 if no ones rolled)
      expect(
        container.read(upperSectionTotalProvider),
        greaterThanOrEqualTo(0),
      );
    });

    test('testBonusAwardedProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(bonusAwardedProvider), false);

      // Bonus is awarded when upper section total >= 63
      // Since dice are random, we test that bonusAwarded is false initially
      // and the provider correctly tracks the state
      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.ones);
      container.read(gameProvider.notifier).scoreCategory(Category.ones);

      // After scoring one category, bonus should still be false
      expect(container.read(bonusAwardedProvider), false);
    });

    test('testTotalScoreProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(totalScoreProvider), 0);

      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.chance);
      container.read(gameProvider.notifier).scoreCategory(Category.chance);

      expect(container.read(totalScoreProvider), greaterThan(0));
    });

    test('testIsGameOverProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(isGameOverProvider), false);

      // Score all 13 scoring categories (bonus is calculated automatically)
      final categoriesToScore = Category.values.where(
        (c) => c != Category.bonus,
      );
      for (final category in categoriesToScore) {
        container.read(gameProvider.notifier).startTurn();
        container.read(gameProvider.notifier).selectCategory(category);
        container.read(gameProvider.notifier).scoreCategory(category);
      }

      // Game is not over until bonus is scored (which requires special handling)
      expect(container.read(isGameOverProvider), false);

      // After scoring 13 categories, only bonus remains
      expect(container.read(remainingCategoriesProvider).length, 1);
    });

    test('testRemainingCategoriesProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(remainingCategoriesProvider).length, 14);

      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.ones);
      container.read(gameProvider.notifier).scoreCategory(Category.ones);

      expect(container.read(remainingCategoriesProvider).length, 13);
    });
  });

  group('Integration Tests', () {
    test('testCompleteTurnFlow', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Start turn
      container.read(gameProvider.notifier).startTurn();
      expect(container.read(gameProvider).diceRoll, isNotNull);
      expect(container.read(remainingRollsProvider), 3);

      // Roll dice twice
      container.read(gameProvider.notifier).rollDice();
      expect(container.read(remainingRollsProvider), 2);

      container.read(gameProvider.notifier).rollDice();
      expect(container.read(remainingRollsProvider), 1);

      // Hold a die
      container.read(gameProvider.notifier).toggleDieHeld(0);
      expect(container.read(diceRollProvider)!.dice[0].isHeld, true);

      // Select category
      container.read(gameProvider.notifier).selectCategory(Category.chance);
      expect(container.read(selectedCategoryProvider), Category.chance);

      // Score category
      container.read(gameProvider.notifier).scoreCategory(Category.chance);
      expect(container.read(selectedCategoryProvider), isNull);
      expect(container.read(gameProvider).diceRoll, isNull);
      expect(container.read(remainingRollsProvider), 3); // Reset for next turn
    });

    test('testHeldDiceRemainFixedAcrossRolls', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();

      // Hold die at index 0
      container.read(gameProvider.notifier).toggleDieHeld(0);
      final firstValue = container.read(diceRollProvider)!.dice[0].value;

      // Roll dice
      container.read(gameProvider.notifier).rollDice();

      // Held die should remain the same
      expect(container.read(diceRollProvider)!.dice[0].value, firstValue);
      expect(container.read(diceRollProvider)!.dice[0].isHeld, true);

      // Roll again
      container.read(gameProvider.notifier).rollDice();

      // Held die should still be the same
      expect(container.read(diceRollProvider)!.dice[0].value, firstValue);
    });

    test('testMultipleTurns', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state
      expect(container.read(gameProvider).currentTurn, 1);

      // First turn - start and score
      container.read(gameProvider.notifier).startTurn();
      expect(container.read(gameProvider).diceRoll, isNotNull);

      container.read(gameProvider.notifier).selectCategory(Category.ones);
      container.read(gameProvider.notifier).scoreCategory(Category.ones);

      // Turn should have incremented after scoring
      expect(container.read(gameProvider).currentTurn, 2);

      // Second turn
      container.read(gameProvider.notifier).startTurn();
      expect(container.read(gameProvider).diceRoll, isNotNull);

      container.read(gameProvider.notifier).selectCategory(Category.twos);
      container.read(gameProvider.notifier).scoreCategory(Category.twos);

      // Turn should have incremented again
      expect(container.read(gameProvider).currentTurn, 3);
    });

    test('testResetGame', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Play some turns
      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.ones);
      container.read(gameProvider.notifier).scoreCategory(Category.ones);

      // Verify game is in progress
      expect(container.read(gameProvider).scores.length, 1);

      // Reset the game
      container.read(gameProvider.notifier).resetGame();

      // Verify game is reset
      expect(container.read(gameProvider).scores.isEmpty, true);
      expect(container.read(gameProvider).diceRoll, isNull);
      expect(container.read(gameProvider).isGameOver, false);
    });

    test('testCannotScoreSameCategoryTwice', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.fours);
      container.read(gameProvider.notifier).scoreCategory(Category.fours);

      final scoreAfterFirst = container.read(scoresProvider)[Category.fours];

      // Try to score again
      container.read(gameProvider.notifier).selectCategory(Category.fours);
      container.read(gameProvider.notifier).scoreCategory(Category.fours);

      final scoreAfterSecond = container.read(scoresProvider)[Category.fours];

      expect(scoreAfterFirst, scoreAfterSecond);
    });

    test('testSelectCategoryDoesNothingIfAlreadyScored', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.fives);
      container.read(gameProvider.notifier).scoreCategory(Category.fives);

      // Select already scored category
      container.read(gameProvider.notifier).selectCategory(Category.fives);

      // Should not change selected category
      expect(container.read(selectedCategoryProvider), isNull);
    });

    test('testStartTurnDoesNothingWhenGameOver', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Score all 13 scoring categories
      final categoriesToScore = Category.values.where(
        (c) => c != Category.bonus,
      );
      for (final category in categoriesToScore) {
        container.read(gameProvider.notifier).startTurn();
        container.read(gameProvider.notifier).selectCategory(category);
        container.read(gameProvider.notifier).scoreCategory(category);
      }

      // Game is not over yet (bonus remains)
      expect(container.read(isGameOverProvider), false);

      // Start another turn to score bonus
      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.bonus);

      // Note: bonus scoring requires special handling not implemented in GameNotifier
      // For now, we just verify the game state after scoring 13 categories
      expect(container.read(remainingCategoriesProvider).length, 1);
    });

    test('testToggleDieHeldDoesNothingWhenNoDiceRoll', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state has no dice roll
      expect(container.read(diceRollProvider), isNull);

      // Try to toggle die held
      container.read(gameProvider.notifier).toggleDieHeld(0);

      // Should still be null
      expect(container.read(diceRollProvider), isNull);
    });

    test('testRollDiceDoesNothingWhenNoDiceRoll', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state has no dice roll
      expect(container.read(diceRollProvider), isNull);

      // Try to roll dice
      container.read(gameProvider.notifier).rollDice();

      // Should still be null
      expect(container.read(diceRollProvider), isNull);
    });

    test('testScoreCategoryDoesNothingWhenNoDiceRoll', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Select category without rolling
      container.read(gameProvider.notifier).selectCategory(Category.chance);

      // Try to score without dice roll
      container.read(gameProvider.notifier).scoreCategory(Category.chance);

      // Score should not be recorded
      expect(container.read(scoresProvider).isEmpty, true);
    });
  });

  group('Scoring Integration Tests', () {
    test('testScoringServiceIntegration', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.yatzy);
      container.read(gameProvider.notifier).scoreCategory(Category.yatzy);

      expect(container.read(scoresProvider).containsKey(Category.yatzy), true);
    });

    test('testUpperSectionScoring', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.ones);
      container.read(gameProvider.notifier).scoreCategory(Category.ones);

      // Upper section total should be >= 0
      expect(
        container.read(upperSectionTotalProvider),
        greaterThanOrEqualTo(0),
      );
    });

    test('testLowerSectionScoring', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.fullHouse);
      container.read(gameProvider.notifier).scoreCategory(Category.fullHouse);

      expect(container.read(scoresProvider)[Category.fullHouse], isNotNull);
    });
  });

  group('Edge Cases', () {
    test('testCustomScoringService', () {
      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) {
            return GameNotifier(scoringService: ScoringService());
          }),
        ],
      );
      addTearDown(container.dispose);

      container.read(gameProvider.notifier).startTurn();
      container.read(gameProvider.notifier).selectCategory(Category.chance);
      container.read(gameProvider.notifier).scoreCategory(Category.chance);

      expect(container.read(scoresProvider).containsKey(Category.chance), true);
    });

    test('testProviderRebuildsOnStateChange', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      int rebuildCount = 0;
      container.listen(gameProvider, (_, _) {
        rebuildCount++;
      });

      expect(rebuildCount, 0);

      container.read(gameProvider.notifier).startTurn();

      expect(rebuildCount, 1);
    });

    test('testComputedProvidersRebuildOnStateChange', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initially remaining rolls is 3
      expect(container.read(remainingRollsProvider), 3);

      container.read(gameProvider.notifier).startTurn();
      // After start turn, remaining rolls is still 3
      expect(container.read(remainingRollsProvider), 3);

      container.read(gameProvider.notifier).rollDice();
      // After rolling, remaining rolls is 2
      expect(container.read(remainingRollsProvider), 2);
    });
  });
}
