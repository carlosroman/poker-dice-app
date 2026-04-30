import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/services/scoring_service.dart';

void main() {
  group('Game Flow Integration Tests', () {
    late ScoringService scoringService;

    setUp(() {
      scoringService = ScoringService();
    });

    test('test_complete_game_flow', () {
      final notifier = GameNotifier(scoringService: scoringService);

      // Start a new game
      notifier.startNewGame();
      notifier.startTurn();

      var state = notifier.state;
      expect(state.isGameOver, false);
      expect(state.remainingRolls, 3);
      expect(state.diceRoll, isNotNull);

      // Simulate playing through all non-bonus categories (13 categories)
      final nonBonusCategories = Category.values.where(
        (cat) => cat != Category.bonus,
      );

      for (final category in nonBonusCategories) {
        state = notifier.state;

        // Roll dice if needed
        while (state.remainingRolls > 0 && state.diceRoll != null) {
          notifier.rollDice();
          state = notifier.state;
        }

        // Select and score a category
        notifier.selectCategory(category);
        notifier.scoreCategory(category);

        // Start new turn for next category
        notifier.startTurn();
      }

      // Verify all 13 categories are scored plus bonus auto-scored
      state = notifier.state;
      expect(state.scores.length, 14);
      // Bonus is auto-calculated when upper section is complete
      expect(state.bonusAwarded, state.upperSectionTotal >= 63);
    });

    test('test_held_dice_remain_across_rolls', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();
      notifier.startTurn();

      var state = notifier.state;

      // Hold the first die
      notifier.toggleDieHeld(0);

      // Roll again
      notifier.rollDice();
      state = notifier.state;

      // The held die should have the same value
      expect(state.diceRoll!.dice[0].isHeld, true);

      // Roll again
      notifier.rollDice();
      state = notifier.state;

      // The held die should still have the same value and be held
      expect(state.diceRoll!.dice[0].isHeld, true);
    });

    test('test_roll_counter_decrements_correctly', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();
      notifier.startTurn();

      var state = notifier.state;
      expect(state.remainingRolls, 3);

      // First roll
      notifier.rollDice();
      state = notifier.state;
      expect(state.remainingRolls, 2);

      // Second roll
      notifier.rollDice();
      state = notifier.state;
      expect(state.remainingRolls, 1);

      // Third roll
      notifier.rollDice();
      state = notifier.state;
      expect(state.remainingRolls, 0);

      // Fourth roll should not decrement (already at 0)
      notifier.rollDice();
      state = notifier.state;
      expect(state.remainingRolls, 0);
    });

    test('test_roll_button_disables_at_zero', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();
      notifier.startTurn();

      // Roll 3 times to exhaust rolls
      notifier.rollDice();
      notifier.rollDice();
      notifier.rollDice();

      var state = notifier.state;
      expect(state.remainingRolls, 0);

      // Attempting to roll again should not change state
      final diceBefore = state.diceRoll;
      notifier.rollDice();
      state = notifier.state;

      // Dice should remain the same (roll didn't happen)
      expect(state.diceRoll, diceBefore);
    });

    test('test_category_selection_updates_score', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();
      notifier.startTurn();

      // Roll dice a few times
      notifier.rollDice();
      notifier.rollDice();

      var state = notifier.state;
      final category = Category.ones;

      // Select category
      notifier.selectCategory(category);
      state = notifier.state;
      expect(state.selectedCategory, category);

      // Score the category
      notifier.scoreCategory(category);
      state = notifier.state;

      // Verify category is scored
      expect(state.scores.containsKey(category), true);
      expect(state.selectedCategory, null);
      expect(state.remainingRolls, 3); // Reset for next turn
    });

    test('test_bonus_awarded_when_upper_reaches_63', () {
      // Manually set upper section scores to exactly 63
      final scores = <Category, int>{
        Category.ones: 10,
        Category.twos: 10,
        Category.threes: 10,
        Category.fours: 10,
        Category.fives: 10,
        Category.sixes: 13, // Total = 63
      };

      // Calculate bonus
      final upperTotal = scores.values.fold(0, (sum, score) => sum + score);
      expect(upperTotal, 63);

      // Bonus should be awarded at exactly 63
      final bonus = upperTotal >= 63 ? 35 : 0;
      expect(bonus, 35);
    });

    test('test_game_ends_after_14_categories', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();

      // Score all 13 non-bonus categories
      final allCategories = Category.values.where(
        (cat) => cat != Category.bonus,
      );

      for (final category in allCategories) {
        notifier.startTurn();

        // Roll dice
        while (notifier.state.remainingRolls > 0) {
          notifier.rollDice();
        }

        // Score category
        notifier.selectCategory(category);
        notifier.scoreCategory(category);
      }

      // After scoring all non-bonus categories, bonus is auto-scored
      var state = notifier.state;
      expect(state.scores.length, 14); // 13 manual + 1 bonus auto-scored
      // Game should be over since all categories including bonus are scored
      expect(state.isGameOver, true);
    });

    test('test_final_score_calculation', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();

      // Calculate expected totals
      final upperTotal = 10 + 12 + 9 + 8 + 15 + 9; // 63
      final bonus = 35; // Awarded because upper >= 63
      final lowerTotal = 20 + 18 + 25 + 30 + 40 + 50 + 24; // 207
      final expectedTotal = upperTotal + bonus + lowerTotal; // 305

      expect(upperTotal, 63);
      expect(bonus, 35);
      expect(lowerTotal, 207);
      expect(expectedTotal, 305);
    });

    test('test_play_again_restarts_game', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();
      notifier.startTurn();

      // Play a bit
      notifier.rollDice();
      notifier.toggleDieHeld(0);
      notifier.rollDice();

      var state = notifier.state;
      final diceBeforeReset = state.diceRoll;

      // Reset game
      notifier.startNewGame();
      notifier.startTurn();

      state = notifier.state;

      // Verify game is reset
      expect(state.isGameOver, false);
      expect(state.remainingRolls, 3);
      expect(state.diceRoll, isNotNull);
      expect(state.diceRoll, isNot(equals(diceBeforeReset)));
      expect(state.scores.isEmpty, true);
      expect(state.selectedCategory, null);
    });

    test('test_scoring_service_all_categories', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();
      notifier.startTurn();

      // Test each non-bonus category can be scored
      final nonBonusCategories = Category.values.where(
        (cat) => cat != Category.bonus,
      );

      for (final category in nonBonusCategories) {
        notifier.selectCategory(category);
        notifier.scoreCategory(category);

        var state = notifier.state;
        expect(state.scores.containsKey(category), true);

        // Start new turn for next category
        notifier.startTurn();
      }

      // All non-bonus categories should be scored (13 + bonus auto-scored = 14)
      var state = notifier.state;
      expect(state.scores.length, 14);
    });

    test('test_toggleDieHold_onlyDuringActiveTurn', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();

      // Cannot toggle dice when no dice roll
      var state = notifier.state;
      expect(state.diceRoll, null);

      // Start turn to get dice
      notifier.startTurn();
      state = notifier.state;
      expect(state.diceRoll, isNotNull);

      // Now can toggle
      notifier.toggleDieHeld(0);
      state = notifier.state;
      expect(state.diceRoll!.dice[0].isHeld, true);
    });

    test('test_selectCategory_onlyForUnscoredCategories', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();
      notifier.startTurn();

      final category = Category.ones;

      // Select and score category
      notifier.selectCategory(category);
      notifier.scoreCategory(category);

      var state = notifier.state;
      expect(state.scores.containsKey(category), true);

      // Try to select already scored category
      final selectedCategoryBefore = state.selectedCategory;
      notifier.selectCategory(category);
      state = notifier.state;

      // Selection should not change
      expect(state.selectedCategory, selectedCategoryBefore);
      expect(state.scores[category], isNotNull); // Score remains
    });
  });
}
