import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/die.dart';

void main() {
  group('Die', () {
    group('constructor', () {
      test('creates die with default values', () {
        final die = Die();

        expect(die.value, 1);
        expect(die.held, false);
      });

      test('creates die with custom values', () {
        final die = Die(value: 5, held: true);

        expect(die.value, 5);
        expect(die.held, true);
      });
    });

    group('roll', () {
      test('generates values between 1 and 6', () {
        final die = Die();

        for (var i = 0; i < 100; i++) {
          final rolledDie = die.roll();
          expect(rolledDie.value, greaterThanOrEqualTo(1));
          expect(rolledDie.value, lessThanOrEqualTo(6));
        }
      });

      test('preserves held state after roll', () {
        final heldDie = Die(value: 3, held: true);
        final rolledHeldDie = heldDie.roll();

        expect(rolledHeldDie.held, true);

        final notHeldDie = Die(value: 3, held: false);
        final rolledNotHeldDie = notHeldDie.roll();

        expect(rolledNotHeldDie.held, false);
      });

      test('returns new instance with rolled value', () {
        final die = Die(value: 1);
        final rolledDie = die.roll();

        expect(rolledDie, isNot(same(die)));
      });
    });

    group('toggleHold', () {
      test('toggles held from false to true', () {
        final die = Die(held: false);
        final toggledDie = die.toggleHold();

        expect(toggledDie.held, true);
      });

      test('toggles held from true to false', () {
        final die = Die(held: true);
        final toggledDie = die.toggleHold();

        expect(toggledDie.held, false);
      });

      test('preserves value after toggle', () {
        final die = Die(value: 4, held: false);
        final toggledDie = die.toggleHold();

        expect(toggledDie.value, 4);
      });

      test('returns new instance', () {
        final die = Die();
        final toggledDie = die.toggleHold();

        expect(toggledDie, isNot(same(die)));
      });
    });

    group('copyWith', () {
      test('creates copy with same values when no arguments provided', () {
        final die = Die(value: 3, held: true);
        final copy = die.copyWith();

        expect(copy.value, 3);
        expect(copy.held, true);
      });

      test('updates value when provided', () {
        final die = Die(value: 1, held: false);
        final copy = die.copyWith(value: 6);

        expect(copy.value, 6);
        expect(copy.held, false);
      });

      test('updates held when provided', () {
        final die = Die(value: 3, held: false);
        final copy = die.copyWith(held: true);

        expect(copy.value, 3);
        expect(copy.held, true);
      });

      test('updates both value and held when provided', () {
        final die = Die(value: 1, held: false);
        final copy = die.copyWith(value: 5, held: true);

        expect(copy.value, 5);
        expect(copy.held, true);
      });
    });

    group('immutability', () {
      test('original die is not modified after roll', () {
        final die = Die(value: 1, held: false);
        die.roll();

        expect(die.value, 1);
        expect(die.held, false);
      });

      test('original die is not modified after toggleHold', () {
        final die = Die(value: 3, held: false);
        die.toggleHold();

        expect(die.value, 3);
        expect(die.held, false);
      });

      test('original die is not modified after copyWith', () {
        final die = Die(value: 1, held: false);
        die.copyWith(value: 6, held: true);

        expect(die.value, 1);
        expect(die.held, false);
      });
    });
  });
}
