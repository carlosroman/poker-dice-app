import 'package:poker_dice/src/domain/game_state.dart';
import 'package:poker_dice/src/domain/models/die.dart';
import 'package:poker_dice/src/domain/models/game_round.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/domain/models/score_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameState', () {
    group('Initialization', () {
      test('creates new game with default values', () {
        final state = GameState();

        expect(state.currentRound.rollCount, 0);
        expect(state.currentRound.dice.length, 5);
        expect(state.scoreSheet.isComplete, false);
        expect(state.isGameOver, false);
        expect(state.totalScore, 0);
      });

      test('creates new game with custom values', () {
        final customRound = GameRound(
          dice: List.generate(5, (i) => Die(value: i + 1, held: false)),
          rollCount: 1,
        );
        final customScoreSheet = ScoreSheet(scores: {ScoreCategory.aces: 5});

        final state = GameState(
          currentRound: customRound,
          scoreSheet: customScoreSheet,
          isGameOver: false,
        );

        expect(state.currentRound.rollCount, 1);
        expect(state.scoreSheet.isCategoryScored(ScoreCategory.aces), true);
        expect(state.isGameOver, false);
      });

      test('copyWith creates a new instance with updated values', () {
        final state = GameState();
        final newState = state.copyWith(isGameOver: true);

        expect(newState.isGameOver, true);
        expect(state.isGameOver, false);
        expect(newState.currentRound, state.currentRound);
        expect(newState.scoreSheet, state.scoreSheet);
      });
    });

    group('rollDice', () {
      test('rolls unheld dice and increments roll count', () {
        final state = GameState();
        final newState = state.rollDice();

        expect(newState.currentRound.rollCount, 1);
        expect(newState.currentRound.dice.length, 5);
        expect(newState.isGameOver, false);
      });

      test('keeps held dice unchanged', () {
        final heldDice = [
          const Die(value: 1, held: true),
          const Die(value: 2, held: true),
          const Die(value: 3, held: false),
          const Die(value: 4, held: false),
          const Die(value: 5, held: false),
        ];
        final round = GameRound(dice: heldDice, rollCount: 0);
        final state = GameState(currentRound: round);

        final newState = state.rollDice();

        expect(newState.currentRound.dice[0].value, 1);
        expect(newState.currentRound.dice[0].held, true);
        expect(newState.currentRound.dice[1].value, 2);
        expect(newState.currentRound.dice[1].held, true);
        // Unheld dice should have new values (may differ from original)
        expect(newState.currentRound.dice[2].held, false);
      });

      test('throws StateError when game is over', () {
        final state = GameState(isGameOver: true);

        expect(() => state.rollDice(), throwsA(isA<StateError>()));
      });

      test('allows multiple rolls up to maximum', () {
        final state = GameState();

        var currentState = state;
        for (int i = 1; i <= 3; i++) {
          currentState = currentState.rollDice();
          expect(currentState.currentRound.rollCount, i);
        }
      });
    });

    group('toggleDie', () {
      test('toggles hold state of die at index after roll', () {
        final dice = List.generate(5, (i) => Die(value: i + 1, held: false));
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);
        final rolledState = state.rollDice();

        final newState = rolledState.toggleDie(2);

        expect(newState.currentRound.dice[2].held, true);
        expect(rolledState.currentRound.dice[2].held, false);
        // Other dice unchanged
        for (int i = 0; i < 5; i++) {
          if (i != 2) {
            expect(newState.currentRound.dice[i].held, false);
          }
        }
      });

      test('toggles held die back to unheld after roll', () {
        final dice = [
          const Die(value: 1, held: true),
          const Die(value: 2, held: false),
          const Die(value: 3, held: false),
          const Die(value: 4, held: false),
          const Die(value: 5, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);
        final rolledState = state.rollDice();

        final newState = rolledState.toggleDie(0);

        expect(newState.currentRound.dice[0].held, false);
      });

      test('throws StateError when game is over', () {
        final state = GameState(isGameOver: true);

        expect(() => state.toggleDie(0), throwsA(isA<StateError>()));
      });

      test('throws RangeError for invalid index', () {
        final state = GameState();

        expect(() => state.toggleDie(-1), throwsA(isA<RangeError>()));
        expect(() => state.toggleDie(5), throwsA(isA<RangeError>()));
        expect(() => state.toggleDie(10), throwsA(isA<RangeError>()));
      });

      test('prevents toggling before first roll', () {
        final state = GameState();

        // Returns the same state without modifying it
        final newState = state.toggleDie(0);
        expect(newState, equals(state));
        expect(newState.currentRound.dice[0].held, isFalse);
      });
    });

    group('selectCategory', () {
      test('scores a category and adds score to sheet', () {
        // Create a round with known dice values
        final dice = [
          const Die(value: 3, held: false),
          const Die(value: 3, held: false),
          const Die(value: 3, held: false),
          const Die(value: 2, held: false),
          const Die(value: 1, held: false),
        ];
        final round = GameRound(dice: dice, rollCount: 1);
        final state = GameState(currentRound: round);

        final newState = state.selectCategory(ScoreCategory.threes);

        expect(
          newState.scoreSheet.isCategoryScored(ScoreCategory.threes),
          true,
        );
        expect(newState.scoreSheet.scores[ScoreCategory.threes], 9);
        expect(newState.isGameOver, false);
      });

      test('starts a new round after scoring', () {
        final dice = [
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
        ];
        final round = GameRound(dice: dice, rollCount: 2);
        final state = GameState(currentRound: round);

        final newState = state.selectCategory(ScoreCategory.aces);

        expect(newState.currentRound.rollCount, 0);
        expect(newState.currentRound.dice.every((d) => !d.held), true);
      });

      test('sets isGameOver to true when all categories are scored', () {
        // Create a complete score sheet
        final scores = <ScoreCategory, int>{};
        for (final category in ScoreCategory.values) {
          scores[category] = 0;
        }
        final completeScoreSheet = ScoreSheet(scores: scores);

        final dice = [
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(
          currentRound: round,
          scoreSheet: completeScoreSheet,
        );

        // Should throw because all categories are already scored
        expect(
          () => state.selectCategory(ScoreCategory.aces),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError for already scored category', () {
        final dice = [
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
        ];
        final round = GameRound(dice: dice);
        final scoreSheet = ScoreSheet(scores: {ScoreCategory.aces: 5});
        final state = GameState(currentRound: round, scoreSheet: scoreSheet);

        expect(
          () => state.selectCategory(ScoreCategory.aces),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws StateError when game is over', () {
        final state = GameState(isGameOver: true);

        expect(
          () => state.selectCategory(ScoreCategory.aces),
          throwsA(isA<StateError>()),
        );
      });

      test('scores Yatzy category and increments yatzyCount', () {
        final dice = [
          const Die(value: 4, held: false),
          const Die(value: 4, held: false),
          const Die(value: 4, held: false),
          const Die(value: 4, held: false),
          const Die(value: 4, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        final newState = state.selectCategory(ScoreCategory.yatzy);

        expect(newState.scoreSheet.isCategoryScored(ScoreCategory.yatzy), true);
        expect(newState.scoreSheet.yatzyCount, 1);
        expect(newState.scoreSheet.scores[ScoreCategory.yatzy], 50);
      });
    });

    group('newGame', () {
      test('resets game to initial state', () {
        // Create a game in progress
        final dice = [
          const Die(value: 6, held: true),
          const Die(value: 6, held: true),
          const Die(value: 6, held: false),
          const Die(value: 6, held: false),
          const Die(value: 6, held: false),
        ];
        final round = GameRound(dice: dice, rollCount: 2);
        final scoreSheet = ScoreSheet(scores: {ScoreCategory.sixes: 30});
        final state = GameState(
          currentRound: round,
          scoreSheet: scoreSheet,
          isGameOver: true,
        );

        final newState = state.newGame();

        expect(newState.currentRound.rollCount, 0);
        expect(newState.scoreSheet.isComplete, false);
        expect(newState.scoreSheet.scores.isEmpty, true);
        expect(newState.isGameOver, false);
        expect(newState.totalScore, 0);
      });

      test('returns fresh GameState with default values', () {
        final state = GameState();
        final newState = state.newGame();

        expect(newState.currentRound.dice.length, 5);
        expect(newState.currentRound.rollCount, 0);
        expect(newState.currentRound.dice.every((d) => !d.held), true);
      });
    });

    group('getValidCategories', () {
      test('returns all categories for new game', () {
        final state = GameState();
        final validCategories = state.getValidCategories();

        expect(validCategories.length, ScoreCategory.values.length);
        expect(validCategories, containsAll(ScoreCategory.values));
      });

      test('returns only unscored categories', () {
        final scoreSheet = ScoreSheet(
          scores: {ScoreCategory.aces: 5, ScoreCategory.twos: 4},
        );
        final state = GameState(scoreSheet: scoreSheet);
        final validCategories = state.getValidCategories();

        expect(validCategories.length, ScoreCategory.values.length - 2);
        expect(validCategories, isNot(contains(ScoreCategory.aces)));
        expect(validCategories, isNot(contains(ScoreCategory.twos)));
        expect(validCategories, contains(ScoreCategory.threes));
      });

      test('returns empty list when all categories scored', () {
        final scores = <ScoreCategory, int>{};
        for (final category in ScoreCategory.values) {
          scores[category] = 0;
        }
        final scoreSheet = ScoreSheet(scores: scores);
        final state = GameState(scoreSheet: scoreSheet);
        final validCategories = state.getValidCategories();

        expect(validCategories.length, 0);
      });
    });

    group('getPotentialScore', () {
      test('returns correct potential for upper categories', () {
        final dice = [
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 2, held: false),
          const Die(value: 3, held: false),
          const Die(value: 4, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        expect(state.getPotentialScore(ScoreCategory.aces), 2);
        expect(state.getPotentialScore(ScoreCategory.twos), 2);
        expect(state.getPotentialScore(ScoreCategory.threes), 3);
        expect(state.getPotentialScore(ScoreCategory.fours), 4);
      });

      test('returns correct potential for Three of a Kind', () {
        final dice = [
          const Die(value: 3, held: false),
          const Die(value: 3, held: false),
          const Die(value: 3, held: false),
          const Die(value: 2, held: false),
          const Die(value: 1, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        expect(state.getPotentialScore(ScoreCategory.threeOfKind), 12);
      });

      test('returns 0 for Three of a Kind when not enough matches', () {
        final dice = [
          const Die(value: 1, held: false),
          const Die(value: 2, held: false),
          const Die(value: 3, held: false),
          const Die(value: 4, held: false),
          const Die(value: 5, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        expect(state.getPotentialScore(ScoreCategory.threeOfKind), 0);
      });

      test('returns correct potential for Four of a Kind', () {
        final dice = [
          const Die(value: 5, held: false),
          const Die(value: 5, held: false),
          const Die(value: 5, held: false),
          const Die(value: 5, held: false),
          const Die(value: 2, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        expect(state.getPotentialScore(ScoreCategory.fourOfKind), 22);
      });

      test('returns correct potential for Full House', () {
        final dice = [
          const Die(value: 2, held: false),
          const Die(value: 2, held: false),
          const Die(value: 5, held: false),
          const Die(value: 5, held: false),
          const Die(value: 5, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        expect(state.getPotentialScore(ScoreCategory.fullHouse), 25);
      });

      test('returns 0 for Full House when not valid', () {
        final dice = [
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 2, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        expect(state.getPotentialScore(ScoreCategory.fullHouse), 0);
      });

      test('returns correct potential for Small Straight', () {
        final dice = [
          const Die(value: 1, held: false),
          const Die(value: 2, held: false),
          const Die(value: 3, held: false),
          const Die(value: 4, held: false),
          const Die(value: 6, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        expect(state.getPotentialScore(ScoreCategory.smallStraight), 30);
      });

      test('returns correct potential for Large Straight', () {
        final dice = [
          const Die(value: 1, held: false),
          const Die(value: 2, held: false),
          const Die(value: 3, held: false),
          const Die(value: 4, held: false),
          const Die(value: 5, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        expect(state.getPotentialScore(ScoreCategory.largeStraight), 40);
      });

      test('returns correct potential for Yatzy', () {
        final dice = [
          const Die(value: 6, held: false),
          const Die(value: 6, held: false),
          const Die(value: 6, held: false),
          const Die(value: 6, held: false),
          const Die(value: 6, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        expect(state.getPotentialScore(ScoreCategory.yatzy), 50);
      });

      test('returns 0 for Yatzy when not all dice match', () {
        final dice = [
          const Die(value: 6, held: false),
          const Die(value: 6, held: false),
          const Die(value: 6, held: false),
          const Die(value: 6, held: false),
          const Die(value: 5, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        expect(state.getPotentialScore(ScoreCategory.yatzy), 0);
      });

      test('returns correct potential for Yatzy with bonus', () {
        final dice = [
          const Die(value: 5, held: false),
          const Die(value: 5, held: false),
          const Die(value: 5, held: false),
          const Die(value: 5, held: false),
          const Die(value: 5, held: false),
        ];
        final round = GameRound(dice: dice);
        final scoreSheet = ScoreSheet(yatzyCount: 1);
        final state = GameState(currentRound: round, scoreSheet: scoreSheet);

        expect(state.getPotentialScore(ScoreCategory.yatzy), 100);
      });

      test('returns correct potential for Chance', () {
        final dice = [
          const Die(value: 1, held: false),
          const Die(value: 2, held: false),
          const Die(value: 3, held: false),
          const Die(value: 4, held: false),
          const Die(value: 5, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        expect(state.getPotentialScore(ScoreCategory.chance), 15);
      });

      test('returns 0 for already scored category', () {
        final dice = [
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
          const Die(value: 1, held: false),
        ];
        final round = GameRound(dice: dice);
        final scoreSheet = ScoreSheet(scores: {ScoreCategory.aces: 5});
        final state = GameState(currentRound: round, scoreSheet: scoreSheet);

        expect(state.getPotentialScore(ScoreCategory.aces), 0);
      });

      test('returns 0 when game is over', () {
        final state = GameState(isGameOver: true);

        expect(state.getPotentialScore(ScoreCategory.aces), 0);
      });
    });

    group('Getters', () {
      test('totalScore returns correct total', () {
        final scoreSheet = ScoreSheet(
          scores: {
            ScoreCategory.aces: 5,
            ScoreCategory.twos: 10,
            ScoreCategory.threes: 15,
          },
        );
        final state = GameState(scoreSheet: scoreSheet);

        expect(state.totalScore, 30);
      });

      test('diceValues returns current dice values', () {
        final dice = [
          const Die(value: 1, held: false),
          const Die(value: 2, held: false),
          const Die(value: 3, held: false),
          const Die(value: 4, held: false),
          const Die(value: 5, held: false),
        ];
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        expect(state.diceValues, [1, 2, 3, 4, 5]);
      });

      test('canRoll returns correct value', () {
        final state1 = GameState();
        expect(state1.canRoll, true);

        final state2 = GameState(currentRound: GameRound(rollCount: 2));
        expect(state2.canRoll, true);

        final state3 = GameState(currentRound: GameRound(rollCount: 3));
        expect(state3.canRoll, false);
      });
    });

    group('Equality and hashCode', () {
      test('equal states are equal', () {
        final state1 = GameState();
        final state2 = GameState();

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('different states are not equal', () {
        final state1 = GameState();
        final state2 = GameState(isGameOver: true);

        expect(state1, isNot(equals(state2)));
      });

      test('states with different score sheets are not equal', () {
        final state1 = GameState();
        final state2 = GameState(
          scoreSheet: ScoreSheet(scores: {ScoreCategory.aces: 5}),
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    group('toString', () {
      test('returns meaningful string representation', () {
        final state = GameState();
        final str = state.toString();

        expect(str, contains('GameState'));
        expect(str, contains('currentRound'));
        expect(str, contains('scoreSheet'));
        expect(str, contains('isGameOver'));
      });
    });

    group('Integration - Complete game flow', () {
      test('plays a complete game from start to finish', () {
        var state = GameState();

        // Play through all categories
        int categoriesPlayed = 0;
        while (!state.isGameOver &&
            categoriesPlayed < ScoreCategory.values.length) {
          // Get valid categories
          final validCategories = state.getValidCategories();
          expect(validCategories.isNotEmpty, true);

          // Pick first valid category
          final category = validCategories.first;

          // Roll dice up to 3 times
          if (state.canRoll) {
            state = state.rollDice();
          }
          if (state.canRoll) {
            state = state.rollDice();
          }
          if (state.canRoll) {
            state = state.rollDice();
          }

          // Score the category
          state = state.selectCategory(category);
          categoriesPlayed++;
        }

        expect(state.isGameOver, true);
        expect(state.scoreSheet.isComplete, true);
        expect(state.totalScore, greaterThanOrEqualTo(0));
      });

      test('handles hold mechanic correctly', () {
        var state = GameState();

        // First roll
        state = state.rollDice();

        // Hold some dice
        state = state.toggleDie(0);
        state = state.toggleDie(1);

        // Second roll - should only roll unheld dice
        final heldBefore = state.currentRound.getHeldDice().length;
        state = state.rollDice();
        final heldAfter = state.currentRound.getHeldDice().length;

        expect(heldBefore, heldAfter);
        expect(heldBefore, 2);
      });

      test('enforces maximum rolls per round', () {
        var state = GameState();

        state = state.rollDice();
        state = state.rollDice();
        state = state.rollDice();

        expect(state.canRoll, false);

        // Should throw when trying to roll again
        expect(() => state.rollDice(), throwsA(isA<StateError>()));
      });
    });

    group('Edge cases', () {
      test('handles all dice held', () {
        final dice = List.generate(5, (i) => const Die(value: 1, held: true));
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        final newState = state.rollDice();

        // All dice should remain unchanged
        for (int i = 0; i < 5; i++) {
          expect(newState.currentRound.dice[i].value, 1);
          expect(newState.currentRound.dice[i].held, true);
        }
      });

      test('handles no dice held', () {
        final dice = List.generate(5, (i) => const Die(value: 1, held: false));
        final round = GameRound(dice: dice);
        final state = GameState(currentRound: round);

        final newState = state.rollDice();

        // All dice should be rolled (values may change)
        expect(newState.currentRound.dice.length, 5);
        expect(newState.currentRound.dice.every((d) => !d.held), true);
      });

      test('handles scoring with all possible patterns', () {
        // Upper section - all ones
        var state = GameState();
        final dice1 = List.filled(5, const Die(value: 1, held: false));
        state = GameState(
          currentRound: GameRound(dice: dice1),
          scoreSheet: state.scoreSheet,
        );
        state = state.selectCategory(ScoreCategory.aces);
        expect(state.scoreSheet.scores[ScoreCategory.aces], 5);

        // Lower section - Yatzy
        final dice2 = List.filled(5, const Die(value: 6, held: false));
        state = GameState(
          currentRound: GameRound(dice: dice2),
          scoreSheet: state.scoreSheet,
        );
        state = state.selectCategory(ScoreCategory.yatzy);
        expect(state.scoreSheet.scores[ScoreCategory.yatzy], 50);
      });

      test('calculates upper section bonus correctly', () {
        // Create a score sheet with upper section >= 63
        final scores = <ScoreCategory, int>{
          ScoreCategory.aces: 11, // Sum of 1s
          ScoreCategory.twos:
              12, // Sum of 2s (six 2s would be 12, but we have 5 dice)
          ScoreCategory.threes: 15,
          ScoreCategory.fours: 16,
          ScoreCategory.fives: 15,
          ScoreCategory.sixes: 12,
        };
        final scoreSheet = ScoreSheet(scores: scores);
        final state = GameState(scoreSheet: scoreSheet);

        expect(state.scoreSheet.getBonus(), 35);
        expect(state.scoreSheet.getMinorTotal(), 81);
        expect(state.totalScore, greaterThan(81));
      });

      test('does not award bonus when minor section < 63', () {
        final scores = <ScoreCategory, int>{
          ScoreCategory.aces: 5,
          ScoreCategory.twos: 10,
          ScoreCategory.threes: 12,
          ScoreCategory.fours: 8,
          ScoreCategory.fives: 10,
          ScoreCategory.sixes: 12,
        };
        final scoreSheet = ScoreSheet(scores: scores);
        final state = GameState(scoreSheet: scoreSheet);

        expect(state.scoreSheet.getBonus(), 0);
        expect(state.scoreSheet.getMinorTotal(), 57);
      });
    });
  });
}
