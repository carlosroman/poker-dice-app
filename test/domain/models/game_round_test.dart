import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/die.dart';
import 'package:poker_dice/src/domain/models/game_round.dart';

void main() {
  group('GameRound', () {
    group('Constructor', () {
      test('creates with default values (5 dice, rollCount=0)', () {
        final gameRound = GameRound();

        expect(gameRound.dice.length, 5);
        expect(gameRound.rollCount, 0);
        expect(gameRound.dice.every((die) => !die.held), true);
        expect(gameRound.dice.every((die) => die.value == 1), true);
      });

      test('creates with custom dice', () {
        final customDice = List<Die>.generate(
          5,
          (index) => Die(value: index + 1, held: index % 2 == 0),
        );
        final gameRound = GameRound(dice: customDice, rollCount: 1);

        expect(gameRound.dice.length, 5);
        expect(gameRound.rollCount, 1);
        expect(gameRound.dice[0].value, 1);
        expect(gameRound.dice[0].held, true);
        expect(gameRound.dice[1].value, 2);
        expect(gameRound.dice[1].held, false);
      });

      test('validates that exactly 5 dice are required', () {
        expect(
          () => GameRound(dice: [Die(), Die(), Die(), Die()]),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => GameRound(dice: [Die(), Die(), Die(), Die(), Die(), Die()]),
          throwsA(isA<ArgumentError>()),
        );

        expect(() => GameRound(dice: []), throwsA(isA<ArgumentError>()));
      });
    });

    group('rollDice', () {
      test('rolls unheld dice', () {
        final dice = [
          const Die(value: 1, held: true),
          const Die(value: 2, held: false),
          const Die(value: 3, held: true),
          const Die(value: 4, held: false),
          const Die(value: 5, held: true),
        ];
        final gameRound = GameRound(dice: dice, rollCount: 0);
        final rolled = gameRound.rollDice();

        expect(rolled.rollCount, 1);
        expect(rolled.dice[0].value, 1); // Held, unchanged
        expect(rolled.dice[2].value, 3); // Held, unchanged
        expect(rolled.dice[4].value, 5); // Held, unchanged
        // Dice at 1 and 3 should have been rolled
        // We verify they were rolled by checking rollCount increased
        // The actual values may coincidentally be the same
        expect(rolled.dice.length, 5);
      });

      test('increments rollCount', () {
        final gameRound = GameRound();
        final rolled = gameRound.rollDice();

        expect(rolled.rollCount, 1);

        final rolledAgain = rolled.rollDice();
        expect(rolledAgain.rollCount, 2);
      });

      test('respects keptIndices parameter', () {
        // Use different initial values to verify which dice were kept vs rolled
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
        ];
        final gameRound = GameRound(dice: dice, rollCount: 0);
        final rolled = gameRound.rollDice([0, 2, 4]);

        expect(rolled.rollCount, 1);
        expect(rolled.dice[0].value, 1); // Kept, unchanged
        expect(rolled.dice[2].value, 3); // Kept, unchanged
        expect(rolled.dice[4].value, 5); // Kept, unchanged
        // Dice at 1 and 3 should have been rolled (may or may not have same value by chance)
        // But the important thing is they weren't explicitly kept
        expect(rolled.dice.length, 5);
      });

      test('does nothing when rollCount >= 3', () {
        final gameRound = GameRound(rollCount: 3);
        final rolled = gameRound.rollDice();

        expect(rolled, same(gameRound));
        expect(rolled.rollCount, 3);
      });

      test('does not modify original instance (immutability)', () {
        final dice = List<Die>.generate(5, (i) => Die(value: i + 1));
        final gameRound = GameRound(dice: dice, rollCount: 0);
        final rolled = gameRound.rollDice();

        expect(gameRound.rollCount, 0);
        expect(gameRound.dice, equals(dice));
        expect(rolled.rollCount, 1);
        expect(rolled.dice, isNot(same(gameRound.dice)));
      });
    });

    group('toggleDie', () {
      test('toggles held state correctly', () {
        final dice = List<Die>.generate(
          5,
          (i) => Die(value: i + 1, held: i == 0),
        );
        final gameRound = GameRound(dice: dice, rollCount: 0);

        final toggled = gameRound.toggleDie(0);
        expect(toggled.dice[0].held, false); // Was true, now false

        final toggledAgain = gameRound.toggleDie(1);
        expect(toggledAgain.dice[1].held, true); // Was false, now true
      });

      test('preserves rollCount after toggle', () {
        final gameRound = GameRound(rollCount: 2);
        final toggled = gameRound.toggleDie(0);

        expect(toggled.rollCount, 2);
      });

      test('throws error for invalid index (negative)', () {
        final gameRound = GameRound();
        expect(() => gameRound.toggleDie(-1), throwsA(isA<ArgumentError>()));
      });

      test('throws error for invalid index (too high)', () {
        final gameRound = GameRound();
        expect(() => gameRound.toggleDie(5), throwsA(isA<ArgumentError>()));
        expect(() => gameRound.toggleDie(10), throwsA(isA<ArgumentError>()));
      });

      test('does not modify original instance (immutability)', () {
        final dice = List<Die>.generate(
          5,
          (i) => const Die(value: 1, held: false),
        );
        final gameRound = GameRound(dice: dice, rollCount: 0);
        final toggled = gameRound.toggleDie(0);

        expect(gameRound.dice[0].held, false);
        expect(toggled.dice[0].held, true);
        expect(toggled.dice, isNot(same(gameRound.dice)));
      });
    });

    group('canRoll', () {
      test('returns true when rollCount is 0', () {
        final gameRound = GameRound(rollCount: 0);
        expect(gameRound.canRoll(), true);
      });

      test('returns true when rollCount is 1', () {
        final gameRound = GameRound(rollCount: 1);
        expect(gameRound.canRoll(), true);
      });

      test('returns true when rollCount is 2', () {
        final gameRound = GameRound(rollCount: 2);
        expect(gameRound.canRoll(), true);
      });

      test('returns false when rollCount is 3', () {
        final gameRound = GameRound(rollCount: 3);
        expect(gameRound.canRoll(), false);
      });

      test('returns false when rollCount exceeds 3', () {
        final gameRound = GameRound(rollCount: 4);
        expect(gameRound.canRoll(), false);
      });
    });

    group('getHeldIndices', () {
      test('returns empty list when no dice are held', () {
        final gameRound = GameRound();
        expect(gameRound.getHeldIndices(), isEmpty);
      });

      test('returns correct indices when some dice are held', () {
        final dice = [
          const Die(value: 1, held: true),
          const Die(value: 2, held: false),
          const Die(value: 3, held: true),
          const Die(value: 4, held: false),
          const Die(value: 5, held: true),
        ];
        final gameRound = GameRound(dice: dice);
        expect(gameRound.getHeldIndices(), equals([0, 2, 4]));
      });

      test('returns all indices when all dice are held', () {
        final dice = List<Die>.generate(5, (_) => const Die(held: true));
        final gameRound = GameRound(dice: dice);
        expect(gameRound.getHeldIndices(), equals([0, 1, 2, 3, 4]));
      });
    });

    group('copyWith', () {
      test('creates new instance with same values when no params provided', () {
        final dice = List<Die>.generate(5, (i) => Die(value: i + 1));
        final gameRound = GameRound(dice: dice, rollCount: 2);
        final copy = gameRound.copyWith();

        expect(copy.dice.length, 5);
        expect(copy.rollCount, 2);
        expect(copy.dice[0].value, 1);
      });

      test('creates new instance with updated dice', () {
        final originalDice = List<Die>.generate(5, (i) => const Die(value: 1));
        final newDice = List<Die>.generate(5, (i) => const Die(value: 6));
        final gameRound = GameRound(dice: originalDice, rollCount: 1);
        final copy = gameRound.copyWith(dice: newDice);

        expect(copy.dice, equals(newDice));
        expect(copy.rollCount, 1);
        expect(copy.dice, isNot(same(gameRound.dice)));
      });

      test('creates new instance with updated rollCount', () {
        final gameRound = GameRound(rollCount: 1);
        final copy = gameRound.copyWith(rollCount: 3);

        expect(copy.rollCount, 3);
        expect(copy.dice, equals(gameRound.dice));
      });

      test('creates new instance with both updated values', () {
        final originalDice = List<Die>.generate(5, (i) => const Die(value: 1));
        final newDice = List<Die>.generate(5, (i) => const Die(value: 6));
        final gameRound = GameRound(dice: originalDice, rollCount: 1);
        final copy = gameRound.copyWith(dice: newDice, rollCount: 3);

        expect(copy.dice, equals(newDice));
        expect(copy.rollCount, 3);
      });
    });

    group('Immutability', () {
      test('original dice list is not modified after rollDice', () {
        final dice = List<Die>.generate(
          5,
          (i) => Die(value: i + 1, held: i == 0),
        );
        final gameRound = GameRound(dice: dice, rollCount: 0);
        final rolled = gameRound.rollDice();

        // Original should still have the same dice values
        expect(gameRound.dice[1].value, 2);
        expect(gameRound.dice[3].value, 4);
        // Original held state should be unchanged
        expect(gameRound.dice[0].held, true);
        expect(
          rolled.dice[1].value,
          isNot(2),
        ); // New instance has different values
      });

      test('original dice list is not modified after toggleDie', () {
        final dice = List<Die>.generate(
          5,
          (i) => const Die(value: 1, held: false),
        );
        final gameRound = GameRound(dice: dice, rollCount: 0);
        final toggled = gameRound.toggleDie(0);

        expect(gameRound.dice[0].held, false);
        expect(toggled.dice[0].held, true);
      });

      test('copyWith creates independent instance', () {
        final dice = List<Die>.generate(5, (i) => const Die(value: 1));
        final gameRound = GameRound(dice: dice, rollCount: 1);
        final newDice = List<Die>.generate(5, (i) => const Die(value: 6));
        final copy = gameRound.copyWith(dice: newDice, rollCount: 3);

        // Modify copy
        final copyToggled = copy.toggleDie(0);

        // Original copy should not be affected
        expect(copy.dice[0].held, false);
        expect(copyToggled.dice[0].held, true);
      });
    });
  });
}
