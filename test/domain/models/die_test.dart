import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/die.dart';

void main() {
  group('Die', () {
    group('initialization', () {
      test('creates die with default values', () {
        final die = const Die();

        expect(die.value, equals(0));
        expect(die.held, isFalse);
      });

      test('creates die with custom values', () {
        const die = Die(value: 5, held: true);

        expect(die.value, equals(5));
        expect(die.held, isTrue);
      });

      test('creates die with only value specified', () {
        const die = Die(value: 3);

        expect(die.value, equals(3));
        expect(die.held, isFalse);
      });

      test('creates die with only held specified', () {
        const die = Die(held: true);

        expect(die.value, equals(0));
        expect(die.held, isTrue);
      });
    });

    group('roll', () {
      test('generates value between 1 and 6', () {
        final die = const Die();
        final rolledDie = die.roll();

        expect(rolledDie.value, greaterThanOrEqualTo(1));
        expect(rolledDie.value, lessThanOrEqualTo(6));
      });

      test('preserves held state when rolling', () {
        const heldDie = Die(held: true);
        final rolledDie = heldDie.roll();

        expect(rolledDie.held, isTrue);
      });

      test('returns new instance, not modifying original', () {
        const original = Die(value: 1, held: false);
        final rolled = original.roll();

        expect(rolled, isNot(equals(original)));
        expect(original.value, equals(1));
      });

      test('can generate different values across multiple rolls', () {
        var die = const Die();
        final values = <int>{};

        // Roll multiple times to check variety
        for (int i = 0; i < 100; i++) {
          final rolled = die.roll();
          values.add(rolled.value);
          die = rolled; // Chain rolls
        }

        expect(values.length, greaterThan(1));
        expect(values.every((v) => v >= 1 && v <= 6), isTrue);
      });
    });

    group('toggleHold', () {
      test('toggles held from false to true for non-blank die', () {
        const die = Die(value: 3, held: false);
        final toggled = die.toggleHold();

        expect(toggled.held, isTrue);
      });

      test('toggles held from true to false for non-blank die', () {
        const die = Die(value: 3, held: true);
        final toggled = die.toggleHold();

        expect(toggled.held, isFalse);
      });

      test('preserves value when toggling hold', () {
        const die = Die(value: 4, held: false);
        final toggled = die.toggleHold();

        expect(toggled.value, equals(4));
      });

      test('returns new instance, not modifying original', () {
        const original = Die(value: 3, held: false);
        final toggled = original.toggleHold();

        expect(toggled, isNot(equals(original)));
        expect(original.held, isFalse);
      });

      test('can toggle multiple times', () {
        const die = Die(value: 3, held: false);
        final toggled1 = die.toggleHold();
        final toggled2 = toggled1.toggleHold();
        final toggled3 = toggled2.toggleHold();

        expect(toggled1.held, isTrue);
        expect(toggled2.held, isFalse);
        expect(toggled3.held, isTrue);
      });

      test('cannot toggle hold for blank die (value 0)', () {
        const blankDie = Die(value: 0, held: false);
        final toggled = blankDie.toggleHold();

        // Returns the same instance for blank dice
        expect(toggled, equals(blankDie));
        expect(toggled.held, isFalse);
      });
    });

    group('copyWith', () {
      test('creates new instance with same values when no args', () {
        const original = Die(value: 5, held: true);
        final copy = original.copyWith();

        expect(copy.value, equals(5));
        expect(copy.held, isTrue);
        expect(copy, equals(original));
      });

      test('creates new instance with updated value', () {
        const original = Die(value: 2, held: false);
        final copy = original.copyWith(value: 6);

        expect(copy.value, equals(6));
        expect(copy.held, isFalse);
      });

      test('creates new instance with updated held state', () {
        const original = Die(value: 3, held: false);
        final copy = original.copyWith(held: true);

        expect(copy.value, equals(3));
        expect(copy.held, isTrue);
      });

      test('creates new instance with both values updated', () {
        const original = Die(value: 1, held: false);
        final copy = original.copyWith(value: 4, held: true);

        expect(copy.value, equals(4));
        expect(copy.held, isTrue);
      });
    });

    group('immutability', () {
      test('original die is not modified after roll', () {
        const original = Die(value: 1, held: false);
        final rolled = original.roll();

        expect(original.value, equals(1));
        expect(original.held, isFalse);
        expect(rolled.value, greaterThanOrEqualTo(1));
        expect(rolled.value, lessThanOrEqualTo(6));
        expect(rolled, isNot(same(original)));
      });

      test('original die is not modified after toggleHold', () {
        const original = Die(value: 3, held: false);
        final toggled = original.toggleHold();

        expect(original.held, isFalse);
        expect(toggled.held, isTrue);
      });

      test('original die is not modified after copyWith', () {
        const original = Die(value: 2, held: false);
        final copy = original.copyWith(value: 5, held: true);

        expect(original.value, equals(2));
        expect(original.held, isFalse);
        expect(copy.value, equals(5));
        expect(copy.held, isTrue);
      });

      test('modifying copy does not affect original', () {
        const original = Die(value: 1, held: false);
        final copy = original.copyWith();
        final modifiedCopy = copy.copyWith(value: 6, held: true);

        expect(original.value, equals(1));
        expect(original.held, isFalse);
        expect(copy.value, equals(1));
        expect(copy.held, isFalse);
        expect(modifiedCopy.value, equals(6));
        expect(modifiedCopy.held, isTrue);
      });
    });

    group('equality', () {
      test('two dice with same values are equal', () {
        const die1 = Die(value: 3, held: false);
        const die2 = Die(value: 3, held: false);

        expect(die1, equals(die2));
      });

      test('dice with different values are not equal', () {
        const die1 = Die(value: 3, held: false);
        const die2 = Die(value: 4, held: false);

        expect(die1, isNot(equals(die2)));
      });

      test('dice with different held states are not equal', () {
        const die1 = Die(value: 3, held: false);
        const die2 = Die(value: 3, held: true);

        expect(die1, isNot(equals(die2)));
      });

      test('hashCode is consistent for equal objects', () {
        const die1 = Die(value: 3, held: false);
        const die2 = Die(value: 3, held: false);

        expect(die1.hashCode, equals(die2.hashCode));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const die = Die(value: 4, held: true);

        expect(die.toString(), equals('Die(value: 4, held: true)'));
      });
    });
  });
}
