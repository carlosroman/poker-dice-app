import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/die.dart';
import 'package:poker_dice/src/domain/models/game_round.dart';

void main() {
  group('GameRound', () {
    group('Initialization', () {
      test('creates round with 5 dice', () {
        final round = GameRound();

        expect(round.dice.length, equals(5));
      });

      test('rollCount starts at 0', () {
        final round = GameRound();

        expect(round.rollCount, equals(0));
      });

      test('accepts custom dice list', () {
        final customDice = List.generate(
          5,
          (i) => Die(value: i + 1, held: false),
        );
        final round = GameRound(dice: customDice);

        expect(round.dice, equals(customDice));
      });

      test('accepts custom rollCount', () {
        final round = GameRound(rollCount: 2);

        expect(round.rollCount, equals(2));
      });
    });

    group('rollDice', () {
      test('rolls unheld dice', () {
        final heldDice = [
          Die(value: 1, held: true),
          Die(value: 2, held: false),
        ];
        final initialDice = [
          ...heldDice,
          Die(value: 3),
          Die(value: 4),
          Die(value: 5),
        ];
        final round = GameRound(dice: initialDice, rollCount: 0);

        final rolledRound = round.rollDice(keptIndices: [0]);

        // First die should remain unchanged (held)
        expect(rolledRound.dice[0].value, equals(1));
        expect(rolledRound.dice[0].held, isTrue);
      });

      test('keeps held dice unchanged', () {
        final heldValue = 6;
        final heldDice = Die(value: heldValue, held: true);
        final initialDice = [heldDice, Die(), Die(), Die(), Die()];
        final round = GameRound(dice: initialDice, rollCount: 0);

        final rolledRound = round.rollDice(keptIndices: [0]);

        expect(rolledRound.dice[0].value, equals(heldValue));
        expect(rolledRound.dice[0].held, isTrue);
      });

      test('increments rollCount', () {
        final round = GameRound(rollCount: 1);

        final rolledRound = round.rollDice();

        expect(rolledRound.rollCount, equals(2));
      });

      test('throws StateError when max rolls reached', () {
        final round = GameRound(rollCount: 3);

        expect(() => round.rollDice(), throwsStateError);
      });

      test('allows rolling when rollCount < 3', () {
        final round = GameRound(rollCount: 2);

        expect(() => round.rollDice(), returnsNormally);
      });
    });

    group('toggleDie', () {
      test('toggles held state from false to true', () {
        final round = GameRound(dice: List.filled(5, const Die(held: false)));

        final toggledRound = round.toggleDie(0);

        expect(toggledRound.dice[0].held, isTrue);
      });

      test('toggles held state from true to false', () {
        final round = GameRound(dice: List.filled(5, const Die(held: true)));

        final toggledRound = round.toggleDie(0);

        expect(toggledRound.dice[0].held, isFalse);
      });

      test('preserves die value when toggling', () {
        const dieValue = 4;
        final round = GameRound(
          dice: [
            Die(value: dieValue, held: false),
            Die(),
            Die(),
            Die(),
            Die(),
          ],
        );

        final toggledRound = round.toggleDie(0);

        expect(toggledRound.dice[0].value, equals(dieValue));
      });

      test('throws RangeError for invalid index', () {
        final round = GameRound();

        expect(() => round.toggleDie(-1), throwsRangeError);
        expect(() => round.toggleDie(5), throwsRangeError);
      });
    });

    group('canRoll', () {
      test('returns true when rollCount is 0', () {
        final round = GameRound(rollCount: 0);

        expect(round.canRoll(), isTrue);
      });

      test('returns true when rollCount is 2', () {
        final round = GameRound(rollCount: 2);

        expect(round.canRoll(), isTrue);
      });

      test('returns false when rollCount is 3', () {
        final round = GameRound(rollCount: 3);

        expect(round.canRoll(), isFalse);
      });
    });

    group('getHeldDice', () {
      test('returns empty list when no dice held', () {
        final round = GameRound(dice: List.filled(5, const Die(held: false)));

        final heldDice = round.getHeldDice();

        expect(heldDice, isEmpty);
      });

      test('returns all held dice', () {
        final dice = [
          const Die(held: true),
          const Die(held: false),
          const Die(held: true),
          const Die(held: false),
          const Die(held: true),
        ];
        final round = GameRound(dice: dice);

        final heldDice = round.getHeldDice();

        expect(heldDice.length, equals(3));
        expect(heldDice.every((die) => die.held), isTrue);
      });
    });

    group('getUnheldDice', () {
      test('returns all dice when none held', () {
        final round = GameRound(dice: List.filled(5, const Die(held: false)));

        final unheldDice = round.getUnheldDice();

        expect(unheldDice.length, equals(5));
        expect(unheldDice.every((die) => !die.held), isTrue);
      });

      test('returns only unheld dice', () {
        final dice = [
          const Die(held: true),
          const Die(held: false),
          const Die(held: true),
          const Die(held: false),
          const Die(held: true),
        ];
        final round = GameRound(dice: dice);

        final unheldDice = round.getUnheldDice();

        expect(unheldDice.length, equals(2));
        expect(unheldDice.every((die) => !die.held), isTrue);
      });
    });

    group('copyWith', () {
      test('creates new instance with same values', () {
        final round = GameRound(
          dice: List.filled(5, const Die(value: 3)),
          rollCount: 1,
        );

        final copy = round.copyWith();

        expect(copy.dice.length, equals(5));
        expect(copy.rollCount, equals(1));
      });

      test('creates new instance with updated dice', () {
        final newDice = List.filled(5, const Die(value: 6));
        final round = GameRound();

        final copy = round.copyWith(dice: newDice);

        expect(copy.dice, equals(newDice));
        expect(identical(copy.dice, round.dice), isFalse);
      });

      test('creates new instance with updated rollCount', () {
        final round = GameRound(rollCount: 1);

        final copy = round.copyWith(rollCount: 2);

        expect(copy.rollCount, equals(2));
      });
    });

    group('Immutability', () {
      test('original round unchanged after rollDice', () {
        final round = GameRound(
          dice: List.filled(5, const Die(value: 1)),
          rollCount: 0,
        );
        final originalDice = List.from(round.dice);
        final originalRollCount = round.rollCount;

        round.rollDice();

        expect(round.dice, equals(originalDice));
        expect(round.rollCount, equals(originalRollCount));
      });

      test('original round unchanged after toggleDie', () {
        final round = GameRound(dice: List.filled(5, const Die(held: false)));

        round.toggleDie(0);

        expect(round.dice[0].held, isFalse);
      });

      test('copyWith does not modify original', () {
        final round = GameRound(rollCount: 1);

        round.copyWith(rollCount: 2);

        expect(round.rollCount, equals(1));
      });
    });
  });
}
