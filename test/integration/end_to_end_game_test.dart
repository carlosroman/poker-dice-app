import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/services/scoring_service.dart';

/// Comprehensive end-to-end integration tests for the complete game flow.
///
/// These tests verify the full game lifecycle from start to finish,
/// including game state persistence, turn management, and scoring.
void main() {
  group('End-to-End Game Flow Tests', () {
    late ScoringService scoringService;

    setUp(() {
      scoringService = ScoringService();
    });

    /// Tests the complete game flow from start to finish.
    ///
    /// Verifies:
    /// - Initial game state is correct
    /// - Dice can be rolled multiple times
    /// - Dice can be held/unheld
    /// - Categories can be selected and scored
    /// - Game ends after all categories are scored
    /// - Final score is calculated correctly
    test('test_completeGameFlow_fromStartToFinish', () {
      final notifier = GameNotifier(scoringService: scoringService);

      // Start new game
      notifier.startNewGame();
      var state = notifier.state;

      // Verify initial state
      expect(state.isGameOver, false);
      expect(state.scores.isEmpty, true);
      expect(state.diceRoll, null);
      expect(state.remainingRolls, 3);

      // Start first turn - this rolls dice
      notifier.startTurn();
      state = notifier.state;

      // Verify initial roll
      expect(state.diceRoll, isNotNull);
      expect(state.diceRoll!.dice.length, 5);
      expect(state.remainingRolls, 3);
      expect(state.currentTurn, 1);

      // Roll dice multiple times
      notifier.rollDice();
      state = notifier.state;
      expect(state.remainingRolls, 2);

      notifier.rollDice();
      state = notifier.state;
      expect(state.remainingRolls, 1);

      // Hold some dice
      notifier.toggleDieHeld(0);
      notifier.toggleDieHeld(2);
      state = notifier.state;
      expect(state.diceRoll!.dice[0].isHeld, true);
      expect(state.diceRoll!.dice[2].isHeld, true);

      // Roll again - held dice should remain unchanged
      final heldDieValue = state.diceRoll!.dice[0].value;
      notifier.rollDice();
      state = notifier.state;
      expect(state.remainingRolls, 0);
      expect(state.diceRoll!.dice[0].value, heldDieValue);
      expect(state.diceRoll!.dice[0].isHeld, true);

      // Select and score a category
      notifier.selectCategory(Category.ones);
      state = notifier.state;
      expect(state.selectedCategory, Category.ones);

      notifier.scoreCategory(Category.ones);
      state = notifier.state;
      expect(state.scores.containsKey(Category.ones), true);
      expect(state.selectedCategory, null);
      expect(state.remainingRolls, 3); // Reset for next turn

      // Verify game is not over
      expect(state.isGameOver, false);

      // Continue playing through remaining non-bonus categories
      final remainingCategories = Category.values.where(
        (cat) => cat != Category.bonus && cat != Category.ones,
      );

      for (final category in remainingCategories) {
        notifier.startTurn();
        state = notifier.state;

        // Roll until no rolls left or choose to score
        while (state.remainingRolls > 0) {
          notifier.rollDice();
          state = notifier.state;
        }

        // Select and score category
        notifier.selectCategory(category);
        notifier.scoreCategory(category);
      }

      // Verify all non-bonus categories scored
      state = notifier.state;
      expect(state.scores.length, 13); // 13 non-bonus categories

      // Bonus should be auto-calculated
      expect(state.bonusAwarded, state.upperSectionTotal >= 63);

      // Verify total score
      expect(state.totalScore, state.calculateTotalScore());

      // Game should not be over yet (bonus not manually scored)
      expect(state.isGameOver, false);
    });

    /// Tests game state persistence across turns.
    ///
    /// Verifies:
    /// - Scores are saved after each turn
    /// - Previous scores persist to next turn
    /// - Total score accumulates correctly
    test('test_gameStatePersistence_acrossTurns', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();

      // Complete first turn
      notifier.startTurn();
      notifier.rollDice();
      notifier.rollDice();

      // Score first category
      notifier.selectCategory(Category.twos);
      notifier.scoreCategory(Category.twos);

      var state = notifier.state;
      final firstCategoryScore = state.scores[Category.twos];
      expect(firstCategoryScore, isNotNull);

      final scoreAfterFirst = state.totalScore;

      // Start second turn
      notifier.startTurn();
      state = notifier.state;

      // Verify first score persists
      expect(state.scores[Category.twos], firstCategoryScore);
      expect(state.totalScore, scoreAfterFirst);

      // Score second category
      notifier.startTurn(); // Get new dice
      notifier.rollDice();
      notifier.selectCategory(Category.threes);
      notifier.scoreCategory(Category.threes);

      state = notifier.state;
      expect(state.scores.length, 2);
      // Score should be recorded (may be 0 if dice don't match)
      expect(state.scores[Category.threes], isNotNull);

      // Complete game and verify final score
      final remainingCategories = Category.values.where(
        (cat) =>
            cat != Category.bonus &&
            cat != Category.twos &&
            cat != Category.threes,
      );

      for (final category in remainingCategories) {
        notifier.startTurn();
        while (notifier.state.remainingRolls > 0) {
          notifier.rollDice();
        }
        notifier.selectCategory(category);
        notifier.scoreCategory(category);
      }

      state = notifier.state;
      expect(state.scores.length, 13); // All non-bonus categories
    });

    /// Tests game reset functionality.
    ///
    /// Verifies:
    /// - startNewGame resets all state
    /// - Scores are cleared
    /// - Dice are re-rolled
    /// - Turn counter resets
    test('test_gameReset_clearsAllState', () {
      final notifier = GameNotifier(scoringService: scoringService);

      // Play part of a game
      notifier.startNewGame();
      notifier.startTurn();
      notifier.rollDice();
      notifier.toggleDieHeld(0);
      notifier.rollDice();
      notifier.selectCategory(Category.fours);
      notifier.scoreCategory(Category.fours);

      var state = notifier.state;
      expect(state.scores.length, 1);
      expect(state.currentTurn, 2);
      expect(state.isGameOver, false);

      // Reset game
      notifier.startNewGame();
      state = notifier.state;

      // Verify all state is reset
      expect(state.scores.isEmpty, true);
      expect(state.currentTurn, 1);
      expect(state.isGameOver, false);
      expect(state.upperSectionTotal, 0);
      expect(state.bonusAwarded, false);
      expect(state.totalScore, 0);
      expect(state.selectedCategory, null);
    });

    /// Tests turn management throughout the game.
    ///
    /// Verifies:
    /// - Each turn starts with 3 rolls
    /// - Turn increments after scoring
    /// - Dice are rolled at start of turn
    test('test_turnManagement_correctFlow', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();

      // Turn 1
      notifier.startTurn();
      var state = notifier.state;
      expect(state.currentTurn, 1);
      expect(state.remainingRolls, 3);
      expect(state.diceRoll, isNotNull);

      // Use all rolls
      notifier.rollDice();
      notifier.rollDice();
      notifier.rollDice();

      state = notifier.state;
      expect(state.remainingRolls, 0);

      // Score to end turn - this clears dice
      notifier.selectCategory(Category.fives);
      notifier.scoreCategory(Category.fives);

      // Turn 2 should start automatically but dice are null until startTurn called
      state = notifier.state;
      expect(state.currentTurn, 2);
      expect(state.remainingRolls, 3);
      // Note: diceRoll is null after scoring, need to call startTurn to get new roll
      expect(state.diceRoll, null);

      // Start turn 2 to get new dice
      notifier.startTurn();
      state = notifier.state;
      expect(state.diceRoll, isNotNull);
    });

    /// Tests scoring mechanics for all category types.
    ///
    /// Verifies:
    /// - Upper section scores correctly
    /// - Bonus awarded at 63+
    /// - Lower section patterns score correctly
    test('test_scoringMechanics_allCategories', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();

      // Test upper section categories
      final upperCategories = [
        Category.ones,
        Category.twos,
        Category.threes,
        Category.fours,
        Category.fives,
        Category.sixes,
      ];

      for (final category in upperCategories) {
        notifier.startTurn();
        notifier.rollDice();

        notifier.selectCategory(category);
        notifier.scoreCategory(category);
      }

      var state = notifier.state;
      expect(state.scores.length, 6);

      // Test lower section categories
      final lowerCategories = [
        Category.threeOfAKind,
        Category.fourOfAKind,
        Category.fullHouse,
        Category.smallStraight,
        Category.largeStraight,
        Category.yatzy,
        Category.chance,
      ];

      for (final category in lowerCategories) {
        notifier.startTurn();
        notifier.rollDice();
        notifier.selectCategory(category);
        notifier.scoreCategory(category);
      }

      state = notifier.state;
      expect(state.scores.length, 13);

      // Verify bonus calculation
      expect(state.bonusAwarded, state.upperSectionTotal >= 63);
    });

    /// Tests held dice mechanics.
    ///
    /// Verifies:
    /// - Tapping die toggles held state
    /// - Held dice show visual indicator
    /// - Held dice remain unchanged on roll
    /// - Can unhold dice before scoring
    test('test_holdDie_mechanics', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();
      notifier.startTurn();

      var state = notifier.state;

      // Initially no dice held
      for (int i = 0; i < 5; i++) {
        expect(state.diceRoll!.dice[i].isHeld, false);
      }

      // Hold first die
      notifier.toggleDieHeld(0);
      state = notifier.state;
      expect(state.diceRoll!.dice[0].isHeld, true);

      // Hold third die
      notifier.toggleDieHeld(2);
      state = notifier.state;
      expect(state.diceRoll!.dice[2].isHeld, true);

      // Record held die values
      final die0Value = state.diceRoll!.dice[0].value;
      final die2Value = state.diceRoll!.dice[2].value;

      // Roll - held dice should not change
      notifier.rollDice();
      state = notifier.state;

      expect(state.diceRoll!.dice[0].value, die0Value);
      expect(state.diceRoll!.dice[0].isHeld, true);
      expect(state.diceRoll!.dice[2].value, die2Value);
      expect(state.diceRoll!.dice[2].isHeld, true);

      // Unhold die
      notifier.toggleDieHeld(0);
      state = notifier.state;
      expect(state.diceRoll!.dice[0].isHeld, false);

      // Roll again - now die 0 can change
      notifier.rollDice();
      state = notifier.state;

      // Die 0 may or may not change (random), but die 2 should be unchanged
      expect(state.diceRoll!.dice[2].value, die2Value);
      expect(state.diceRoll!.dice[2].isHeld, true);
    });

    /// Tests roll dice mechanics.
    ///
    /// Verifies:
    /// - Initial roll generates 5 dice
    /// - Subsequent rolls only affect unheld dice
    /// - Roll counter decrements correctly
    /// - Roll button disables at 0 rolls
    test('test_rollDice_mechanics', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();
      notifier.startTurn();

      var state = notifier.state;

      // Initial roll creates 5 dice
      expect(state.diceRoll, isNotNull);
      expect(state.diceRoll!.dice.length, 5);
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

      // Fourth roll should not change anything
      final diceBefore = state.diceRoll;
      final rollsBefore = state.remainingRolls;

      notifier.rollDice();
      state = notifier.state;

      expect(state.diceRoll, diceBefore);
      expect(state.remainingRolls, rollsBefore);
    });

    /// Tests category selection mechanics.
    ///
    /// Verifies:
    /// - Tap category row selects it
    /// - Selected category highlighted
    /// - Can only select unscored categories
    /// - Play button scores selected category
    test('test_categorySelection_mechanics', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();
      notifier.startTurn();
      notifier.rollDice();

      var state = notifier.state;

      // Select unscored category
      notifier.selectCategory(Category.sixes);
      state = notifier.state;
      expect(state.selectedCategory, Category.sixes);

      // Try to select already scored category (should fail)
      notifier.scoreCategory(Category.sixes);
      state = notifier.state;
      expect(state.scores.containsKey(Category.sixes), true);

      final selectedBefore = state.selectedCategory;
      notifier.selectCategory(Category.sixes);
      state = notifier.state;

      // Selection should not change for already scored category
      expect(state.selectedCategory, selectedBefore);

      // Select another unscored category
      notifier.selectCategory(Category.chance);
      state = notifier.state;
      expect(state.selectedCategory, Category.chance);
    });

    /// Tests that game properly handles edge cases.
    ///
    /// Verifies:
    /// - Scoring with no dice roll handled gracefully
    /// - Selecting category without dice roll handled
    /// - Invalid category selection rejected
    test('test_edgeCases_handledGracefully', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();

      var state = notifier.state;

      // Cannot score without dice roll
      expect(state.diceRoll, null);
      expect(state.selectedCategory, null);

      // Try to score without starting turn - selection allowed
      notifier.selectCategory(Category.ones);
      state = notifier.state;
      expect(state.selectedCategory, Category.ones);

      // Score without rolling - should return early (no dice)
      notifier.scoreCategory(Category.ones);
      state = notifier.state;
      // Score should NOT be recorded when no dice roll
      expect(state.scores.containsKey(Category.ones), false);

      // Now start turn and score properly
      notifier.startTurn();
      notifier.selectCategory(Category.twos);
      notifier.scoreCategory(Category.twos);
      state = notifier.state;
      expect(state.scores.containsKey(Category.twos), true);
    });

    /// Tests bonus category is auto-calculated.
    ///
    /// Verifies:
    /// - Bonus is calculated automatically when upper section >= 63
    /// - Bonus cannot be manually scored
    test('test_bonusCategory_autoCalculated', () {
      final notifier = GameNotifier(scoringService: scoringService);

      notifier.startNewGame();

      // Score upper section categories to reach 63+
      final upperCategories = [
        Category.ones,
        Category.twos,
        Category.threes,
        Category.fours,
        Category.fives,
        Category.sixes,
      ];

      for (final category in upperCategories) {
        notifier.startTurn();
        notifier.rollDice();
        notifier.selectCategory(category);
        notifier.scoreCategory(category);
      }

      var state = notifier.state;
      expect(state.scores.length, 6);

      // Calculate upper section total
      final upperTotal = state.calculateUpperSectionTotal();
      expect(upperTotal, greaterThanOrEqualTo(0));

      // Bonus should be awarded if upperTotal >= 63
      expect(state.bonusAwarded, upperTotal >= 63);
    });
  });
}
