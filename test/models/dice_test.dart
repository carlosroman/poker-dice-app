import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';

void main() {
  group('Dice', () {
    test('creates with valid value and default isHeld', () {
      final dice = Dice(value: 3);

      expect(dice.value, 3);
      expect(dice.isHeld, false);
    });

    test('creates with valid value and isHeld true', () {
      final dice = Dice(value: 5, isHeld: true);

      expect(dice.value, 5);
      expect(dice.isHeld, true);
    });

    test('throws assertion error for value less than 1', () {
      expect(() => Dice(value: 0), throwsA(isA<AssertionError>()));
      expect(() => Dice(value: -1), throwsA(isA<AssertionError>()));
    });

    test('throws assertion error for value greater than 6', () {
      expect(() => Dice(value: 7), throwsA(isA<AssertionError>()));
      expect(() => Dice(value: 100), throwsA(isA<AssertionError>()));
    });

    test('accepts boundary values 1 and 6', () {
      expect(() => Dice(value: 1), returnsNormally);
      expect(() => Dice(value: 6), returnsNormally);
    });

    group('copyWith', () {
      test('returns a new instance with unchanged values', () {
        final dice = Dice(value: 3, isHeld: false);
        final copy = dice.copyWith();

        expect(identical(copy, dice), isFalse);
        expect(copy.value, 3);
        expect(copy.isHeld, false);
      });

      test('updates value when provided', () {
        final dice = Dice(value: 2);
        final updated = dice.copyWith(value: 4);

        expect(updated.value, 4);
        expect(updated.isHeld, dice.isHeld);
      });

      test('updates isHeld when provided', () {
        final dice = Dice(value: 2, isHeld: false);
        final updated = dice.copyWith(isHeld: true);

        expect(updated.isHeld, true);
        expect(updated.value, dice.value);
      });

      test('updates both value and isHeld', () {
        final dice = Dice(value: 1, isHeld: false);
        final updated = dice.copyWith(value: 6, isHeld: true);

        expect(updated.value, 6);
        expect(updated.isHeld, true);
      });

      test('throws assertion error when copyWith value is invalid', () {
        final dice = Dice(value: 3);

        expect(() => dice.copyWith(value: 0), throwsA(isA<AssertionError>()));
        expect(() => dice.copyWith(value: 7), throwsA(isA<AssertionError>()));
      });
    });

    group('equality', () {
      test('same value and isHeld are equal', () {
        final a = Dice(value: 4, isHeld: true);
        final b = Dice(value: 4, isHeld: true);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different value are not equal', () {
        final a = Dice(value: 3, isHeld: false);
        final b = Dice(value: 5, isHeld: false);

        expect(a, isNot(equals(b)));
      });

      test('different isHeld are not equal', () {
        final a = Dice(value: 3, isHeld: false);
        final b = Dice(value: 3, isHeld: true);

        expect(a, isNot(equals(b)));
      });

      test('identical instances are equal', () {
        final dice = Dice(value: 2);

        expect(dice, equals(dice));
      });

      test('not equal to non-Dice objects', () {
        final dice = Dice(value: 1);

        expect(dice, isNot(equals('not a dice')));
        expect(dice, isNot(equals(42)));
      });
    });

    test('toString returns readable representation', () {
      final dice = Dice(value: 5, isHeld: true);

      expect(dice.toString(), 'Dice(value: 5, isHeld: true)');
    });
  });
}
