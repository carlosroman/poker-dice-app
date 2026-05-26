import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/die.dart';
import 'package:poker_dice/models/dice_roll.dart';
import 'package:poker_dice/models/game_state.dart';

void main() {
  group('GameState', () {
    test('test_default_state_initializes_correctly', () {
      final state = GameState();

      expect(state.currentRollsRemaining, equals(3));
      expect(state.currentDiceRoll, isNull);
      expect(state.selectedCategory, isNull);
      expect(state.scores.length, equals(14));
      expect(state.upperSectionTotal, equals(0));
      expect(state.bonusAwarded, isFalse);
      expect(state.totalScore, equals(0));
      expect(state.isGameOver, isFalse);
    });

    test('test_all_scores_start_as_null', () {
      final state = GameState();
      for (final cat in Category.values) {
        expect(state.scores[cat], isNull);
      }
    });

    test('test_addScore_records_score', () {
      final state = GameState();
      final newState = state.addScore(Category.ones, 6);

      expect(newState.scores[Category.ones], equals(6));
      expect(state.scores[Category.ones], isNull); // original unchanged
    });

    test('test_addScore_updates_upperSectionTotal', () {
      final state = GameState()
          .addScore(Category.ones, 6)
          .addScore(Category.twos, 4);

      expect(state.upperSectionTotal, equals(10));
    });

    test('test_addScore_updates_totalScore', () {
      final state = GameState()
          .addScore(Category.ones, 6)
          .addScore(Category.yatzy, 50);

      expect(state.totalScore, equals(56));
    });

    test('test_bonusAwarded_when_upper_total_meets_threshold', () {
      final state = GameState()
          .addScore(Category.ones, 15)
          .addScore(Category.twos, 12)
          .addScore(Category.threes, 9)
          .addScore(Category.fours, 8)
          .addScore(Category.fives, 10)
          .addScore(Category.sixes, 15);

      expect(state.upperSectionTotal, equals(69));
      expect(state.bonusAwarded, isTrue);
    });

    test('test_bonusAwarded_false_below_threshold', () {
      final state = GameState()
          .addScore(Category.ones, 3)
          .addScore(Category.twos, 4);

      expect(state.bonusAwarded, isFalse);
    });

    test('test_totalScore_includes_bonus_when_earned', () {
      final state = GameState()
          .addScore(Category.ones, 15)
          .addScore(Category.twos, 12)
          .addScore(Category.threes, 9)
          .addScore(Category.fours, 8)
          .addScore(Category.fives, 10)
          .addScore(Category.sixes, 15)
          .addScore(Category.yatzy, 50);

      expect(
        state.totalScore,
        equals(154),
      ); // 69 + 35 bonus + 50 yatzy // 69 + 35 bonus + 50 yatzy
    });

    test('test_isGameOver_true_when_all_scored', () {
      var state = GameState();
      for (final cat in Category.values) {
        state = state.addScore(cat, 0);
      }
      expect(state.isGameOver, isTrue);
    });

    test('test_isGameOver_false_when_one_unscored', () {
      var state = GameState();
      for (final cat in Category.values.take(13)) {
        state = state.addScore(cat, 0);
      }
      expect(state.isGameOver, isFalse);
    });

    test('test_selectCategory_sets_selection', () {
      final state = GameState();
      final newState = state.selectCategory(Category.ones);

      expect(newState.selectedCategory, equals(Category.ones));
      expect(state.selectedCategory, isNull); // original unchanged
    });

    test('test_selectCategory_resets_rolls', () {
      final state = GameState();
      final newState = state.selectCategory(Category.ones);

      expect(newState.currentRollsRemaining, equals(0));
    });

    test('test_selectCategory_null_clears_selection', () {
      final state = GameState();
      final withSelection = state.selectCategory(Category.ones);
      final cleared = withSelection.selectCategory(null);

      expect(cleared.selectedCategory, isNull);
    });

    test('test_rollDice_creates_initial_roll', () {
      final state = GameState();
      final newState = state.rollDice();

      expect(newState.currentDiceRoll, isNotNull);
      expect(newState.currentDiceRoll!.dice.length, equals(5));
      expect(newState.currentRollsRemaining, equals(2));
    });

    test('test_rollDice_decrements_rolls', () {
      var state = GameState();
      state = state.rollDice();
      expect(state.currentRollsRemaining, equals(2));

      state = state.rollDice();
      expect(state.currentRollsRemaining, equals(1));

      state = state.rollDice();
      expect(state.currentRollsRemaining, equals(0));
    });

    test('test_rollDice_no_op_when_no_rolls_left', () {
      var state = GameState();
      state = state.rollDice();
      state = state.rollDice();
      state = state.rollDice();
      final before = state;
      final after = state.rollDice();

      expect(after.currentRollsRemaining, equals(0));
      expect(after.currentDiceRoll, equals(before.currentDiceRoll));
    });

    test('test_toggleDieHold_toggles_die', () {
      final dice = [
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
        Die(value: 5),
      ];
      final state = GameState(currentDiceRoll: DiceRoll(dice: dice));

      final withHeld = state.toggleDieHold(0);
      expect(withHeld.currentDiceRoll!.dice[0].isHeld, isTrue);
      expect(state.currentDiceRoll!.dice[0].isHeld, isFalse); // original

      final unheld = withHeld.toggleDieHold(0);
      expect(unheld.currentDiceRoll!.dice[0].isHeld, isFalse);
    });

    test('test_toggleDieHold_no_op_without_dice', () {
      final state = GameState();
      final newState = state.toggleDieHold(0);
      expect(newState.currentDiceRoll, isNull);
    });

    test('test_copyWith_updates_fields', () {
      final state = GameState();
      final newState = state.copyWith(currentRollsRemaining: 1);

      expect(newState.currentRollsRemaining, equals(1));
      expect(state.currentRollsRemaining, equals(3));
    });

    test('test_copyWith_null_keeps_original', () {
      final state = GameState(currentRollsRemaining: 2);
      final newState = state.copyWith();

      expect(newState.currentRollsRemaining, equals(2));
    });

    test('test_reset_returns_fresh_state', () {
      var state = GameState();
      state = state.rollDice();
      state = state.addScore(Category.ones, 6);

      final reset = state.reset();

      expect(reset.currentRollsRemaining, equals(3));
      expect(reset.currentDiceRoll, isNull);
      expect(reset.selectedCategory, isNull);
      expect(reset.totalScore, equals(0));
    });

    test('test_equality_works', () {
      final state1 = GameState();
      final state2 = GameState();

      expect(state1, equals(state2));
    });

    test('test_equality_differs_with_scores', () {
      final state1 = GameState();
      final state2 = GameState().addScore(Category.ones, 6);

      expect(state1, isNot(equals(state2)));
    });

    test('test_toString_contains_state_info', () {
      final state = GameState();
      final str = state.toString();

      expect(str, contains('GameState'));
      expect(str, contains('rolls'));
      expect(str, contains('total'));
    });

    test('test_resetTurn_clears_turn_state', () {
      final dice = [
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
        Die(value: 5),
      ];
      final state = GameState(
        currentRollsRemaining: 1,
        currentDiceRoll: DiceRoll(dice: dice),
        selectedCategory: Category.ones,
      );

      final reset = state.resetTurn();

      expect(reset.currentRollsRemaining, equals(3));
      expect(reset.currentDiceRoll, isNull);
      expect(reset.selectedCategory, isNull);
    });
  });
}
