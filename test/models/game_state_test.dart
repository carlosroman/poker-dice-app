import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/game_state.dart';

void main() {
  group('GameState', () {
    test('default state initializes correctly', () {
      final state = const GameState();

      expect(state.currentRollsRemaining, equals(3));
      expect(state.diceRoll, isNull);
      expect(state.isRolling, isFalse);
      expect(state.selectedCategory, isNull);
      expect(state.scores, isEmpty);
      expect(state.upperSectionTotal, equals(0));
      expect(state.bonusAwarded, equals(0));
      expect(state.totalScore, equals(0));
      expect(state.isGameOver, isFalse);
    });

    test('addScore records score', () {
      final state = const GameState();
      final newState = state.addScore('ones', 6);

      expect(newState.scores['ones'], equals(6));
      expect(state.scores['ones'], isNull); // original unchanged
    });

    test('addScore ignores duplicate categories', () {
      var state = const GameState();
      state = state.addScore('ones', 5);
      expect(state.scores['ones'], equals(5));

      final stateAfterSecond = state.addScore('ones', 10);
      expect(stateAfterSecond.scores['ones'], equals(5));
      expect(identical(state, stateAfterSecond), isTrue);
    });

    test('addScore updates upperSectionTotal', () {
      final state = const GameState()
          .addScore('ones', 6)
          .addScore('twos', 4);

      expect(state.upperSectionTotal, equals(10));
    });

    test('addScore updates totalScore', () {
      final state = const GameState()
          .addScore('ones', 6)
          .addScore('yatzy', 50);

      expect(state.totalScore, equals(56));
    });

    test('bonusAwarded when upper total meets threshold', () {
      final state = const GameState()
          .addScore('ones', 15)
          .addScore('twos', 12)
          .addScore('threes', 9)
          .addScore('fours', 8)
          .addScore('fives', 10)
          .addScore('sixes', 15);

      expect(state.upperSectionTotal, equals(69));
      expect(state.bonusAwarded, equals(50));
    });

    test('bonusAwarded is 0 below threshold', () {
      final state = const GameState()
          .addScore('ones', 3)
          .addScore('twos', 4);

      expect(state.bonusAwarded, equals(0));
    });

    test('totalScore includes bonus when earned', () {
      final state = const GameState()
          .addScore('ones', 15)
          .addScore('twos', 12)
          .addScore('threes', 9)
          .addScore('fours', 8)
          .addScore('fives', 10)
          .addScore('sixes', 15)
          .addScore('yatzy', 50);

      expect(state.totalScore, equals(169)); // 69 upper + 50 bonus + 50 yatzy
    });

    test('selectCategory sets selection', () {
      final state = const GameState();
      final newState = state.selectCategory('ones');

      expect(newState.selectedCategory, equals('ones'));
      expect(state.selectedCategory, isNull); // original unchanged
    });

    test('selectCategory null clears selection', () {
      final state = const GameState();
      final withSelection = state.selectCategory('ones');
      final cleared = withSelection.selectCategory(null);

      expect(cleared.selectedCategory, isNull);
    });

    test('rollDice creates roll state', () {
      final state = const GameState();
      final newState = state.rollDice([1, 2, 3, 4, 5]);

      expect(newState.diceRoll, isNotNull);
      expect(newState.diceRoll, equals([1, 2, 3, 4, 5]));
      expect(newState.isRolling, isTrue);
    });

    test('copyWith updates fields', () {
      final state = const GameState();
      final newState = state.copyWith(currentRollsRemaining: 1);

      expect(newState.currentRollsRemaining, equals(1));
      expect(state.currentRollsRemaining, equals(3));
    });

    test('copyWith null keeps original', () {
      final state = const GameState(currentRollsRemaining: 2);
      final newState = state.copyWith();

      expect(newState.currentRollsRemaining, equals(2));
    });

    test('reset returns fresh state', () {
      final state = const GameState()
          .rollDice([1, 2, 3, 4, 5])
          .addScore('ones', 6);

      final reset = state.reset();

      expect(reset.currentRollsRemaining, equals(3));
      expect(reset.diceRoll, isNull);
      expect(reset.selectedCategory, isNull);
      expect(reset.totalScore, equals(0));
    });

    test('resetTurn clears turn state', () {
      final state = const GameState(
        currentRollsRemaining: 1,
        diceRoll: [1, 2, 3, 4, 5],
        selectedCategory: 'ones',
        isRolling: true,
      );

      final reset = state.resetTurn();

      expect(reset.currentRollsRemaining, equals(3));
      expect(reset.diceRoll, isNull);
      expect(reset.selectedCategory, isNull);
      expect(reset.isRolling, isFalse);
    });

    test('decrementRolls reduces remaining rolls', () {
      final state = const GameState();
      final newState = state.decrementRolls();

      expect(newState.currentRollsRemaining, equals(2));
    });

    test('isGameOver is false when not all categories scored', () {
      final state = const GameState().addScore('ones', 6);
      expect(state.isGameOver, isFalse);
    });

    test('isGameOver is true when all categories scored', () {
      var state = const GameState();
      for (final cat in Category.values) {
        state = state.addScore(cat.name, 10);
      }
      expect(state.isGameOver, isTrue);
    });

    test('isGameOver is false when one category missing', () {
      var state = const GameState();
      for (final cat in Category.values) {
        if (cat != Category.chance) {
          state = state.addScore(cat.name, 10);
        }
      }
      expect(state.isGameOver, isFalse);
    });

    test('endGame returns current state', () {
      final state = const GameState();
      final newState = state.endGame();

      expect(identical(newState, state), isTrue);
    });

    test('isRolling defaults to false', () {
      final state = const GameState();
      expect(state.isRolling, isFalse);
    });

    test('isRolling can be set via copyWith', () {
      final state = const GameState();
      final newState = state.copyWith(isRolling: true);

      expect(newState.isRolling, isTrue);
    });

    // -- Held dice tests --

    test('heldDice defaults to null, effectiveHeldDice returns all false', () {
      final state = const GameState();

      expect(state.heldDice, isNull);
      expect(state.effectiveHeldDice, equals([false, false, false, false, false]));
    });

    test('heldDice can be set via constructor', () {
      final state = const GameState(
        heldDice: [true, false, true, false, false],
      );

      expect(state.heldDice, equals([true, false, true, false, false]));
      expect(state.effectiveHeldDice, equals([true, false, true, false, false]));
    });

    test('toggleHeldDie flips the held state at index', () {
      final state = const GameState();
      final toggled = state.toggleHeldDie(0);

      expect(toggled.effectiveHeldDice, equals([true, false, false, false, false]));
      expect(state.effectiveHeldDice, equals([false, false, false, false, false]));
    });

    test('toggleHeldDie is idempotent (toggle twice returns to original)', () {
      final state = const GameState();
      final toggledOnce = state.toggleHeldDie(2);
      final toggledTwice = toggledOnce.toggleHeldDie(2);

      expect(toggledOnce.effectiveHeldDice, equals([false, false, true, false, false]));
      expect(toggledTwice.effectiveHeldDice, equals([false, false, false, false, false]));
    });

    test('toggleHeldDie preserves other dice held state', () {
      final state = const GameState(
        heldDice: [true, false, false, true, false],
      );
      final toggled = state.toggleHeldDie(1);

      expect(toggled.effectiveHeldDice, equals([true, true, false, true, false]));
    });

    test('toggleHeldDie throws on negative index', () {
      final state = const GameState();

      expect(() => state.toggleHeldDie(-1), throwsA(isA<ArgumentError>()));
    });

    test('toggleHeldDie throws on index >= 5', () {
      final state = const GameState();

      expect(() => state.toggleHeldDie(5), throwsA(isA<ArgumentError>()));
    });

    test('resetTurn clears held dice', () {
      final state = const GameState(
        heldDice: [true, true, false, true, false],
        diceRoll: [1, 2, 3, 4, 5],
      );
      final reset = state.resetTurn();

      expect(reset.effectiveHeldDice, equals([false, false, false, false, false]));
    });

    test('addScore clears held dice', () {
      final state = const GameState(
        heldDice: [true, false, true, false, false],
      );
      final scored = state.addScore('ones', 6);

      expect(scored.effectiveHeldDice, equals([false, false, false, false, false]));
    });

    test('copyWith preserves held dice when not provided', () {
      final state = const GameState(
        heldDice: [true, false, true, false, false],
      );
      final copied = state.copyWith(currentRollsRemaining: 2);

      expect(copied.heldDice, equals([true, false, true, false, false]));
      expect(copied.currentRollsRemaining, equals(2));
    });

    test('copyWith updates held dice when provided', () {
      final state = const GameState(
        heldDice: [true, false, true, false, false],
      );
      final copied = state.copyWith(heldDice: const [false, true, false, true, false]);

      expect(copied.heldDice, equals([false, true, false, true, false]));
    });

    test('rollDice preserves held dice', () {
      final state = const GameState(
        heldDice: [true, false, false, true, false],
      );
      final rolled = state.rollDice([3, 5, 1, 2, 6]);

      expect(rolled.diceRoll, equals([3, 5, 1, 2, 6]));
      expect(rolled.heldDice, equals([true, false, false, true, false]));
    });

    test('effectiveHeldDice returns defaults for invalid heldDice length', () {
      final state = GameState(heldDice: const [true, false]);

      expect(state.effectiveHeldDice, equals([false, false, false, false, false]));
    });

    // -- Potential score tests --

    test('getPotentialScore returns null when no dice rolled', () {
      final state = const GameState();

      expect(state.getPotentialScore('ones'), isNull);
    });

    test('getPotentialScore returns null for already scored category', () {
      final state = const GameState(
        scores: {'ones': 6},
        diceRoll: [1, 1, 2, 3, 4],
      );

      expect(state.getPotentialScore('ones'), isNull);
    });

    test('getPotentialScore calculates score for ones', () {
      final state = const GameState(diceRoll: [1, 1, 2, 3, 4]);

      expect(state.getPotentialScore('ones'), equals(2));
    });

    test('getPotentialScore calculates score for twos', () {
      final state = const GameState(diceRoll: [2, 2, 2, 3, 4]);

      expect(state.getPotentialScore('twos'), equals(6));
    });

    test('getPotentialScore returns 0 when no matching dice', () {
      final state = const GameState(diceRoll: [2, 3, 4, 5, 6]);

      expect(state.getPotentialScore('ones'), equals(0));
    });

    test('getPotentialScore calculates score for six of a kind (Yatzy)', () {
      final state = const GameState(diceRoll: [5, 5, 5, 5, 5]);

      expect(state.getPotentialScore('yatzy'), equals(50));
    });

    test('getPotentialScore returns 0 for Yatzy when not all same', () {
      final state = const GameState(diceRoll: [1, 2, 3, 4, 5]);

      expect(state.getPotentialScore('yatzy'), equals(0));
    });

    test('getPotentialScore calculates full house score', () {
      final state = const GameState(diceRoll: [3, 3, 3, 5, 5]);

      expect(state.getPotentialScore('fullHouse'), equals(25));
    });

    test('getPotentialScore returns 0 for full house when not matching', () {
      final state = const GameState(diceRoll: [1, 2, 3, 4, 5]);

      expect(state.getPotentialScore('fullHouse'), equals(0));
    });

    test('getPotentialScore calculates chance score', () {
      final state = const GameState(diceRoll: [3, 4, 5, 6, 1]);

      expect(state.getPotentialScore('chance'), equals(19));
    });

    test('getPotentialScore throws for invalid category name', () {
      final state = const GameState(diceRoll: [1, 2, 3, 4, 5]);

      expect(
        () => state.getPotentialScore('invalid_category'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
