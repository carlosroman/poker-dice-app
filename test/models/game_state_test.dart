import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/models/score_category.dart';

void main() {
  group('GameState', () {
    group('initial state', () {
      test('creates with 5 dice via initial factory', () {
        final state = GameState.initial();

        expect(state.currentDice.length, 5);
        expect(state.rollsRemaining, 3);
        expect(state.status, GameStatus.active);
      });

      test('all categories start unscored', () {
        final state = GameState.initial();

        for (final category in ScoreCategory.values) {
          expect(
            state.scoredCategories[category],
            isNull,
            reason: '$category should be null initially',
          );
        }
      });

      test('totalScore is 0 initially', () {
        final state = GameState.initial();

        expect(state.totalScore, 0);
      });

      test('upperSectionTotal is 0 initially', () {
        final state = GameState.initial();

        expect(state.upperSectionTotal, 0);
      });

      test('hasBonus is false initially', () {
        final state = GameState.initial();

        expect(state.hasBonus, isFalse);
      });

      test('bonus is 0 initially', () {
        final state = GameState.initial();

        expect(state.bonus, 0);
      });

      test('isGameComplete is false initially', () {
        final state = GameState.initial();

        expect(state.isGameComplete, isFalse);
      });
    });

    group('constructor validation', () {
      test('throws ArgumentError when dice count is not 5', () {
        expect(
          () => GameState(currentDice: [Dice(value: 1), Dice(value: 2)]),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => GameState(
            currentDice: [
              Dice(value: 1),
              Dice(value: 2),
              Dice(value: 3),
              Dice(value: 4),
              Dice(value: 5),
              Dice(value: 6),
            ],
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('rollDice', () {
      test('replaces dice and decrements rollsRemaining', () {
        final state = GameState.initial();
        final newDice = [
          Dice(value: 3),
          Dice(value: 5),
          Dice(value: 1),
          Dice(value: 4),
          Dice(value: 2),
        ];
        final newState = state.rollDice(newDice);

        expect(newState.currentDice, newDice);
        expect(newState.rollsRemaining, 2);
        expect(state.rollsRemaining, 3); // original unchanged
      });

      test('throws ArgumentError when newDice count is not 5', () {
        final state = GameState.initial();

        expect(
          () => state.rollDice([Dice(value: 1), Dice(value: 2)]),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws StateError when no rolls remaining', () {
        final state = GameState(rollsRemaining: 0);

        expect(
          () => state.rollDice(List.generate(5, (i) => Dice(value: 1))),
          throwsA(isA<StateError>()),
        );
      });

      test('preserves scored categories', () {
        final scored = Map<ScoreCategory, int?>.fromEntries(
          ScoreCategory.values.map((c) => MapEntry(c, null)),
        );
        scored[ScoreCategory.aces] = 6;
        final state = GameState(scoredCategories: scored);

        final newState = state.rollDice(
          List.generate(5, (i) => Dice(value: 2)),
        );

        expect(newState.scoredCategories[ScoreCategory.aces], 6);
      });
    });

    group('toggleHold', () {
      test('toggles held state on at index', () {
        final dice = List.generate(5, (i) => Dice(value: i + 1));
        final state = GameState(currentDice: dice);

        final newState = state.toggleHold(2);

        expect(newState.currentDice[2].isHeld, isTrue);
        for (int i = 0; i < 5; i++) {
          if (i != 2) {
            expect(newState.currentDice[i].isHeld, isFalse);
          }
        }
      });

      test('toggles held state off', () {
        final dice = [
          Dice(value: 1),
          Dice(value: 2, isHeld: true),
          Dice(value: 3),
          Dice(value: 4),
          Dice(value: 5),
        ];
        final state = GameState(currentDice: dice);

        final newState = state.toggleHold(1);

        expect(newState.currentDice[1].isHeld, isFalse);
      });

      test('throws RangeError for out of bounds index', () {
        final state = GameState.initial();

        expect(() => state.toggleHold(-1), throwsA(isA<RangeError>()));
        expect(() => state.toggleHold(5), throwsA(isA<RangeError>()));
      });

      test('does not mutate original state', () {
        final dice = List.generate(5, (i) => Dice(value: i + 1));
        final state = GameState(currentDice: dice);

        state.toggleHold(0);

        expect(state.currentDice[0].isHeld, isFalse);
      });
    });

    group('scoreCategory', () {
      test('records a score for a category', () {
        final state = GameState.initial();
        final newState = state.scoreCategory(ScoreCategory.aces, 6);

        expect(newState.scoredCategories[ScoreCategory.aces], 6);
        expect(newState.totalScore, 6);
      });

      test('throws StateError when category already scored', () {
        final state = GameState.initial().scoreCategory(ScoreCategory.twos, 4);

        expect(
          () => state.scoreCategory(ScoreCategory.twos, 8),
          throwsA(isA<StateError>()),
        );
      });

      test('allows zero scores', () {
        final state = GameState.initial();
        final newState = state.scoreCategory(ScoreCategory.aces, 0);

        expect(newState.scoredCategories[ScoreCategory.aces], 0);
      });

      test('updates totalScore correctly', () {
        final state = GameState.initial()
            .scoreCategory(ScoreCategory.aces, 6)
            .scoreCategory(ScoreCategory.twos, 4);

        expect(state.totalScore, 10);
      });

      test('transitions to completed when all categories scored', () {
        GameState state = GameState.initial();
        for (final category in ScoreCategory.values) {
          state = state.scoreCategory(category, 0);
        }

        expect(state.status, GameStatus.completed);
        expect(state.isGameComplete, isTrue);
      });

      test('remains active when not all categories scored', () {
        final state = GameState.initial().scoreCategory(ScoreCategory.aces, 6);

        expect(state.status, GameStatus.active);
        expect(state.isGameComplete, isFalse);
      });
    });

    group('upperSectionTotal', () {
      test('sums only upper section scores', () {
        final scored = Map<ScoreCategory, int?>.fromEntries(
          ScoreCategory.values.map((c) => MapEntry(c, null)),
        );
        scored[ScoreCategory.aces] = 5;
        scored[ScoreCategory.fives] = 10;
        scored[ScoreCategory.yatzy] = 50;

        final state = GameState(scoredCategories: scored);

        expect(state.upperSectionTotal, 15);
      });

      test('ignores unscored upper categories', () {
        final scored = Map<ScoreCategory, int?>.fromEntries(
          ScoreCategory.values.map((c) => MapEntry(c, null)),
        );
        scored[ScoreCategory.aces] = 3;

        final state = GameState(scoredCategories: scored);

        expect(state.upperSectionTotal, 3);
      });
    });

    group('bonus', () {
      test('hasBonus is true when upperSectionTotal >= 63', () {
        final scored = Map<ScoreCategory, int?>.fromEntries(
          ScoreCategory.values.map((c) => MapEntry(c, null)),
        );
        // 6 dice each showing 6 in upper = 6*6 = 36, but we need 63+
        // Use max: each upper category has 5 dice at max value
        // Aces: 5, Twos: 10, Threes: 15, Fours: 20, Fives: 25, Sixes: 30 => 105
        scored[ScoreCategory.aces] = 5;
        scored[ScoreCategory.twos] = 10;
        scored[ScoreCategory.threes] = 15;
        scored[ScoreCategory.fours] = 20;
        scored[ScoreCategory.fives] = 25;
        scored[ScoreCategory.sixes] = 30;

        final state = GameState(scoredCategories: scored);

        expect(state.hasBonus, isTrue);
        expect(state.bonus, 35);
      });

      test('hasBonus is false when upperSectionTotal < 63', () {
        final scored = Map<ScoreCategory, int?>.fromEntries(
          ScoreCategory.values.map((c) => MapEntry(c, null)),
        );
        scored[ScoreCategory.aces] = 1;
        scored[ScoreCategory.twos] = 2;

        final state = GameState(scoredCategories: scored);

        expect(state.hasBonus, isFalse);
        expect(state.bonus, 0);
      });

      test('bonus is included in totalScore', () {
        final scored = Map<ScoreCategory, int?>.fromEntries(
          ScoreCategory.values.map((c) => MapEntry(c, null)),
        );
        scored[ScoreCategory.aces] = 5;
        scored[ScoreCategory.twos] = 10;
        scored[ScoreCategory.threes] = 15;
        scored[ScoreCategory.fours] = 20;
        scored[ScoreCategory.fives] = 25;
        scored[ScoreCategory.sixes] = 30;
        scored[ScoreCategory.yatzy] = 50;

        final state = GameState(scoredCategories: scored);

        // Upper: 105 + Yatzy: 50 + Bonus: 35 = 190
        expect(state.totalScore, 190);
      });
    });

    group('isGameComplete', () {
      test('is false when any category is unscored', () {
        final scored = Map<ScoreCategory, int?>.fromEntries(
          ScoreCategory.values.map((c) => MapEntry(c, 0)),
        );
        scored[ScoreCategory.chance] = null;

        final state = GameState(scoredCategories: scored);

        expect(state.isGameComplete, isFalse);
      });

      test('is true when all categories have scores', () {
        final scored = Map<ScoreCategory, int?>.fromEntries(
          ScoreCategory.values.map((c) => MapEntry(c, 0)),
        );

        final state = GameState(scoredCategories: scored);

        expect(state.isGameComplete, isTrue);
      });
    });

    group('copyWith', () {
      test('returns new instance with unchanged values', () {
        final state = GameState.initial();
        final copy = state.copyWith();

        expect(identical(copy, state), isFalse);
        expect(copy.currentDice, state.currentDice);
        expect(copy.rollsRemaining, state.rollsRemaining);
        expect(copy.status, state.status);
      });

      test('updates rollsRemaining when provided', () {
        final state = GameState.initial();
        final updated = state.copyWith(rollsRemaining: 1);

        expect(updated.rollsRemaining, 1);
        expect(state.rollsRemaining, 3);
      });

      test('updates status when provided', () {
        final state = GameState.initial();
        final updated = state.copyWith(status: GameStatus.completed);

        expect(updated.status, GameStatus.completed);
        expect(state.status, GameStatus.active);
      });

      test('updates currentDice when provided', () {
        final newDice = List.generate(5, (i) => Dice(value: 6));
        final state = GameState.initial();
        final updated = state.copyWith(currentDice: newDice);

        expect(updated.currentDice, newDice);
      });

      test('updates scoredCategories when provided', () {
        final state = GameState.initial();
        final newCategories = Map<ScoreCategory, int?>.from(
          state.scoredCategories,
        );
        newCategories[ScoreCategory.aces] = 5;

        final updated = state.copyWith(scoredCategories: newCategories);

        expect(updated.scoredCategories[ScoreCategory.aces], 5);
        expect(state.scoredCategories[ScoreCategory.aces], isNull);
      });
    });
  });
}
