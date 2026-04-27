import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/dice_roll.dart';
import 'package:poker_dice/models/game_state.dart';

void main() {
  group('GameState Constructor Tests', () {
    test('creates initial state with no dice', () {
      final state = GameState();

      expect(state.diceRoll, isNull);
    });

    test('creates initial state with empty scores', () {
      final state = GameState();

      expect(state.scores.isEmpty, true);
    });

    test('creates initial state with no selected category', () {
      final state = GameState();

      expect(state.selectedCategory, isNull);
    });

    test('creates initial state with 3 rolls remaining', () {
      final state = GameState();

      expect(state.remainingRolls, 3);
    });

    test('creates initial state with turn 1', () {
      final state = GameState();

      expect(state.currentTurn, 1);
    });

    test('creates initial state with isGameOver false', () {
      final state = GameState();

      expect(state.isGameOver, false);
    });

    test('creates initial state with upperSectionTotal 0', () {
      final state = GameState();

      expect(state.upperSectionTotal, 0);
    });

    test('creates initial state with bonusAwarded false', () {
      final state = GameState();

      expect(state.bonusAwarded, false);
    });

    test('creates initial state with totalScore 0', () {
      final state = GameState();

      expect(state.totalScore, 0);
    });

    test('accepts custom initial scores', () {
      final scores = {Category.ones: 5, Category.twos: 4};
      final state = GameState(scores: scores);

      expect(state.scores[Category.ones], 5);
      expect(state.scores[Category.twos], 4);
    });

    test('accepts custom initial dice roll', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll);

      expect(state.diceRoll, isNotNull);
      expect(state.diceRoll!.dice[0].value, 1);
    });
  });

  group('Constants', () {
    test('maxRollsPerTurn equals 3', () {
      expect(GameState.maxRollsPerTurn, 3);
    });

    test('upperSectionTarget equals 63', () {
      expect(GameState.upperSectionTarget, 63);
    });

    test('bonusPoints equals 35', () {
      expect(GameState.bonusPoints, 35);
    });
  });

  group('startTurn', () {
    test('rolls dice and sets remainingRolls to 3', () {
      final state = GameState();
      final newState = state.startTurn();

      expect(newState.diceRoll, isNotNull);
      expect(newState.remainingRolls, 3);
    });

    test('clears selected category', () {
      final state = GameState(selectedCategory: Category.ones);
      final newState = state.startTurn();

      expect(newState.selectedCategory, isNull);
    });

    test('keeps scores unchanged', () {
      final scores = {Category.ones: 5};
      final state = GameState(scores: scores);
      final newState = state.startTurn();

      expect(newState.scores[Category.ones], 5);
    });

    test('keeps current turn unchanged', () {
      final state = GameState(currentTurn: 2);
      final newState = state.startTurn();

      expect(newState.currentTurn, 2);
    });

    test('keeps isGameOver false', () {
      final state = GameState();
      final newState = state.startTurn();

      expect(newState.isGameOver, false);
    });

    test('returns same state if game is over', () {
      final state = GameState(isGameOver: true);
      final newState = state.startTurn();

      expect(newState, state);
    });

    test('creates new dice roll instance', () {
      final state = GameState();
      final newState = state.startTurn();

      expect(newState.diceRoll, isNotNull);
      expect(newState.diceRoll!.dice.length, 5);
    });
  });

  group('toggleDieHeld', () {
    test('toggles held state of die at index', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll);
      final newState = state.toggleDieHeld(2);

      expect(state.diceRoll!.dice[2].isHeld, false);
      expect(newState.diceRoll!.dice[2].isHeld, true);
    });

    test('toggles from held to not held', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll).toggleDieHeld(2);
      final newState = state.toggleDieHeld(2);

      expect(state.diceRoll!.dice[2].isHeld, true);
      expect(newState.diceRoll!.dice[2].isHeld, false);
    });

    test('returns same state if diceRoll is null', () {
      final state = GameState();
      final newState = state.toggleDieHeld(0);

      expect(newState, state);
    });

    test('returns same state for invalid index (negative)', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll);
      final newState = state.toggleDieHeld(-1);

      expect(newState, state);
    });

    test('returns same state for invalid index (out of range)', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll);
      final newState = state.toggleDieHeld(5);

      expect(newState, state);
    });

    test('keeps other fields unchanged', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(
        diceRoll: diceRoll,
        scores: {Category.ones: 5},
        selectedCategory: Category.twos,
        remainingRolls: 2,
        currentTurn: 3,
      );
      final newState = state.toggleDieHeld(0);

      expect(newState.scores[Category.ones], 5);
      expect(newState.selectedCategory, Category.twos);
      expect(newState.remainingRolls, 2);
      expect(newState.currentTurn, 3);
    });
  });

  group('rollDice', () {
    test('rolls unheld dice and decrements remainingRolls', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll, remainingRolls: 3);
      final newState = state.rollDice();

      expect(newState.remainingRolls, 2);
      expect(newState.diceRoll, isNotNull);
    });

    test('keeps held dice unchanged', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final heldDiceRoll = diceRoll.toggleDieHeld(2);
      final state = GameState(diceRoll: heldDiceRoll, remainingRolls: 3);
      final newState = state.rollDice();

      expect(newState.diceRoll!.dice[2].value, 3);
      expect(newState.diceRoll!.dice[2].isHeld, true);
    });

    test('returns same state if diceRoll is null', () {
      final state = GameState(remainingRolls: 3);
      final newState = state.rollDice();

      expect(newState, state);
    });

    test('does not roll when remainingRolls is 0', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll, remainingRolls: 0);
      final newState = state.rollDice();

      expect(newState, state);
    });

    test('does not roll when remainingRolls is negative', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll, remainingRolls: -1);
      final newState = state.rollDice();

      expect(newState, state);
    });

    test('keeps scores unchanged', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(
        diceRoll: diceRoll,
        scores: {Category.ones: 5},
        remainingRolls: 3,
      );
      final newState = state.rollDice();

      expect(newState.scores[Category.ones], 5);
    });
  });

  group('selectCategory', () {
    test('sets selected category for unscored category', () {
      final state = GameState();
      final newState = state.selectCategory(Category.ones);

      expect(newState.selectedCategory, Category.ones);
    });

    test('returns same state if category already scored', () {
      final scores = {Category.ones: 5};
      final state = GameState(scores: scores);
      final newState = state.selectCategory(Category.ones);

      expect(newState, state);
    });

    test('keeps dice roll unchanged', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll);
      final newState = state.selectCategory(Category.twos);

      expect(newState.diceRoll, diceRoll);
    });

    test('keeps scores unchanged', () {
      final scores = {Category.ones: 5};
      final state = GameState(scores: scores);
      final newState = state.selectCategory(Category.twos);

      expect(newState.scores[Category.ones], 5);
    });
  });

  group('scoreCategory', () {
    test('records score for category', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll);
      final newState = state.scoreCategory(Category.ones, 10);

      expect(newState.scores[Category.ones], 10);
    });

    test('returns same state if category already scored', () {
      final scores = {Category.ones: 5};
      final state = GameState(scores: scores);
      final newState = state.scoreCategory(Category.ones, 10);

      expect(newState, state);
    });

    test('clears dice roll after scoring', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll);
      final newState = state.scoreCategory(Category.ones, 10);

      expect(newState.diceRoll, isNull);
    });

    test('clears selected category after scoring', () {
      final state = GameState(selectedCategory: Category.ones);
      final newState = state.scoreCategory(Category.twos, 8);

      expect(newState.selectedCategory, isNull);
    });

    test('resets remainingRolls to 3 after scoring', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll, remainingRolls: 1);
      final newState = state.scoreCategory(Category.ones, 10);

      expect(newState.remainingRolls, 3);
    });

    test('increments turn after scoring', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll, currentTurn: 2);
      final newState = state.scoreCategory(Category.ones, 10);

      expect(newState.currentTurn, 3);
    });

    test('calculates upper section total correctly', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll);
      final newState = state.scoreCategory(Category.ones, 5);

      expect(newState.upperSectionTotal, 5);
    });

    test('updates upper section total with multiple scores', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll);
      final state2 = state.scoreCategory(Category.ones, 5);
      final state3 = state2.scoreCategory(Category.twos, 8);

      expect(state3.upperSectionTotal, 13);
    });

    test('marks game as over when all categories scored', () {
      // Create a state with all categories except one scored
      final scores = {
        Category.ones: 5,
        Category.twos: 8,
        Category.threes: 9,
        Category.fours: 12,
        Category.fives: 15,
        Category.sixes: 18,
        Category.threeOfAKind: 10,
        Category.fourOfAKind: 12,
        Category.fullHouse: 25,
        Category.smallStraight: 20,
        Category.largeStraight: 20,
        Category.yatzy: 50,
        Category.chance: 25,
      };
      final state = GameState(scores: scores);
      final newState = state.scoreCategory(Category.bonus, 35);

      expect(newState.isGameOver, true);
    });

    test('does not mark game as over when categories remain', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll);
      final newState = state.scoreCategory(Category.ones, 5);

      expect(newState.isGameOver, false);
    });
  });

  group('calculateUpperSectionTotal', () {
    test('returns 0 when no upper section scores', () {
      final state = GameState();

      expect(state.calculateUpperSectionTotal(), 0);
    });

    test('sums upper section scores correctly', () {
      final scores = {
        Category.ones: 5,
        Category.twos: 8,
        Category.threes: 9,
        Category.fours: 12,
        Category.fives: 15,
        Category.sixes: 18,
      };
      final state = GameState(scores: scores);

      expect(state.calculateUpperSectionTotal(), 67);
    });

    test('ignores lower section scores', () {
      final scores = {
        Category.threeOfAKind: 10,
        Category.fourOfAKind: 12,
        Category.fullHouse: 25,
      };
      final state = GameState(scores: scores);

      expect(state.calculateUpperSectionTotal(), 0);
    });

    test('handles partial upper section scores', () {
      final scores = {Category.ones: 5, Category.twos: 8};
      final state = GameState(scores: scores);

      expect(state.calculateUpperSectionTotal(), 13);
    });

    test('calculateUpperSectionTotalWithScores works with custom scores', () {
      final state = GameState();
      final scores = {Category.ones: 5, Category.twos: 8};

      expect(state.calculateUpperSectionTotalWithScores(scores), 13);
    });
  });

  group('calculateBonus', () {
    test('returns 0 when upper section total is less than 63', () {
      final scores = {
        Category.ones: 5,
        Category.twos: 8,
        Category.threes: 9,
        Category.fours: 12,
        Category.fives: 15,
        Category.sixes: 12,
      };
      final state = GameState(scores: scores);

      expect(state.calculateBonus(), 0);
    });

    test('returns 35 when upper section total equals 63', () {
      final scores = {
        Category.ones: 5,
        Category.twos: 8,
        Category.threes: 9,
        Category.fours: 12,
        Category.fives: 15,
        Category.sixes: 14,
      };
      final state = GameState(scores: scores);

      expect(state.calculateBonus(), 35);
    });

    test('returns 35 when upper section total exceeds 63', () {
      final scores = {
        Category.ones: 5,
        Category.twos: 8,
        Category.threes: 9,
        Category.fours: 12,
        Category.fives: 15,
        Category.sixes: 18,
      };
      final state = GameState(scores: scores);

      expect(state.calculateBonus(), 35);
    });

    test('calculateBonusWithScores works with custom scores', () {
      final state = GameState();
      final scores = {
        Category.ones: 10,
        Category.twos: 10,
        Category.threes: 10,
        Category.fours: 10,
        Category.fives: 10,
        Category.sixes: 13,
      };

      expect(state.calculateBonusWithScores(scores), 35);
    });
  });

  group('calculateTotalScore', () {
    test('returns 0 when no scores', () {
      final state = GameState();

      expect(state.calculateTotalScore(), 0);
    });

    test('sums all scores without bonus', () {
      final scores = {
        Category.ones: 5,
        Category.twos: 8,
        Category.threeOfAKind: 10,
      };
      final state = GameState(scores: scores, bonusAwarded: false);

      expect(state.calculateTotalScore(), 23);
    });

    test('includes bonus when bonusAwarded is true', () {
      final scores = {
        Category.ones: 5,
        Category.twos: 8,
        Category.threes: 9,
        Category.fours: 12,
        Category.fives: 15,
        Category.sixes: 14,
      };
      final state = GameState(scores: scores, bonusAwarded: true);

      expect(state.calculateTotalScore(), 98); // 63 + 35 bonus
    });

    test('calculateTotalScoreWithScores works with custom scores', () {
      final state = GameState();
      final scores = {
        Category.ones: 5,
        Category.twos: 8,
        Category.threeOfAKind: 10,
      };

      expect(state.calculateTotalScoreWithScores(scores, false), 23);
      expect(state.calculateTotalScoreWithScores(scores, true), 58);
    });
  });

  group('getRemainingCategories', () {
    test('returns all categories when none scored', () {
      final state = GameState();
      final remaining = state.getRemainingCategories();

      expect(remaining.length, 14);
      expect(remaining.contains(Category.ones), true);
      expect(remaining.contains(Category.bonus), true);
    });

    test('returns categories excluding scored ones', () {
      final scores = {Category.ones: 5, Category.twos: 8};
      final state = GameState(scores: scores);
      final remaining = state.getRemainingCategories();

      expect(remaining.length, 12);
      expect(remaining.contains(Category.ones), false);
      expect(remaining.contains(Category.twos), false);
      expect(remaining.contains(Category.threes), true);
    });

    test('returns empty list when all categories scored', () {
      final scores = {
        Category.ones: 5,
        Category.twos: 8,
        Category.threes: 9,
        Category.fours: 12,
        Category.fives: 15,
        Category.sixes: 18,
        Category.threeOfAKind: 10,
        Category.fourOfAKind: 12,
        Category.fullHouse: 25,
        Category.smallStraight: 20,
        Category.largeStraight: 20,
        Category.yatzy: 50,
        Category.chance: 25,
        Category.bonus: 35,
      };
      final state = GameState(scores: scores);
      final remaining = state.getRemainingCategories();

      expect(remaining.isEmpty, true);
    });

    test('getRemainingCategoriesWithScores works with custom scores', () {
      final state = GameState();
      final scores = {Category.ones: 5};

      expect(state.getRemainingCategoriesWithScores(scores).length, 13);
    });
  });

  group('canScoreCategory', () {
    test('returns true for unscored category with dice roll', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(diceRoll: diceRoll);

      expect(state.canScoreCategory(Category.ones), true);
    });

    test('returns false for scored category', () {
      final scores = {Category.ones: 5};
      final state = GameState(scores: scores);

      expect(state.canScoreCategory(Category.ones), false);
    });

    test('returns false when no dice roll', () {
      final state = GameState();

      expect(state.canScoreCategory(Category.ones), false);
    });
  });

  group('isGameOver', () {
    test('returns false initially', () {
      final state = GameState();

      expect(state.isGameOver, false);
    });

    test('returns false when some categories scored', () {
      final scores = {Category.ones: 5};
      final state = GameState(scores: scores);

      expect(state.isGameOver, false);
    });

    test('returns true when all categories scored', () {
      final scores = {
        Category.ones: 5,
        Category.twos: 8,
        Category.threes: 9,
        Category.fours: 12,
        Category.fives: 15,
        Category.sixes: 18,
        Category.threeOfAKind: 10,
        Category.fourOfAKind: 12,
        Category.fullHouse: 25,
        Category.smallStraight: 20,
        Category.largeStraight: 20,
        Category.yatzy: 50,
        Category.chance: 25,
        Category.bonus: 35,
      };
      final state = GameState(scores: scores, isGameOver: true);

      expect(state.isGameOver, true);
    });
  });

  group('copyWith', () {
    test('creates copy with same values when no parameters provided', () {
      final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final state = GameState(
        diceRoll: diceRoll,
        scores: {Category.ones: 5},
        selectedCategory: Category.twos,
        remainingRolls: 2,
        currentTurn: 3,
        isGameOver: false,
        upperSectionTotal: 5,
        bonusAwarded: false,
        totalScore: 5,
      );
      final copy = state.copyWith();

      expect(copy.diceRoll, state.diceRoll);
      expect(copy.scores, equals(state.scores));
      expect(copy.selectedCategory, state.selectedCategory);
      expect(copy.remainingRolls, state.remainingRolls);
      expect(copy.currentTurn, state.currentTurn);
      expect(copy.isGameOver, state.isGameOver);
      expect(copy.upperSectionTotal, state.upperSectionTotal);
      expect(copy.bonusAwarded, state.bonusAwarded);
      expect(copy.totalScore, state.totalScore);
    });

    test('creates copy with updated fields', () {
      final state = GameState();
      final copy = state.copyWith(
        remainingRolls: 2,
        currentTurn: 5,
        isGameOver: true,
      );

      expect(copy.remainingRolls, 2);
      expect(copy.currentTurn, 5);
      expect(copy.isGameOver, true);
    });

    test('returns new instance', () {
      final state = GameState();
      final copy = state.copyWith();

      expect(copy, isNot(same(state)));
    });

    test('scores map is copied, not referenced', () {
      final state = GameState(scores: {Category.ones: 5});
      final copy = state.copyWith();

      copy.scores[Category.twos] = 8;

      expect(state.scores.containsKey(Category.twos), false);
    });
  });
}
