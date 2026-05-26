import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/die.dart';

void main() {
  group('Die', () {
    test('test_die_value_is_between_1_and_6', () {
      final die = Die();
      expect(die.value, inInclusiveRange(1, 6));
    });

    test('test_die_default_value_is_random', () {
      final dice = List<Die>.generate(100, (_) => Die());
      final values = dice.map((d) => d.value).toSet();
      expect(values.length, greaterThan(1));
    });

    test('test_die_explicit_value_works', () {
      for (final v in [1, 2, 3, 4, 5, 6]) {
        final die = Die(value: v);
        expect(die.value, equals(v));
      }
    });

    test('test_isHeld_defaults_to_false', () {
      final die = Die();
      expect(die.isHeld, isFalse);
    });

    test('test_toggleHold_changes_state', () {
      final die = Die(value: 1);
      expect(die.isHeld, isFalse);

      final toggled = die.toggleHold();
      expect(toggled.isHeld, isTrue);
      expect(toggled.value, equals(1));
      expect(die.isHeld, isFalse); // original unchanged
    });

    test('test_multiple_toggleHold_calls', () {
      var die = Die(value: 3);
      expect(die.isHeld, isFalse);

      die = die.toggleHold();
      expect(die.isHeld, isTrue);

      die = die.toggleHold();
      expect(die.isHeld, isFalse);

      die = die.toggleHold();
      expect(die.isHeld, isTrue);
    });

    test('test_die_equality', () {
      final die1 = Die(value: 4, isHeld: true);
      final die2 = Die(value: 4, isHeld: true);
      final die3 = Die(value: 4, isHeld: false);
      final die4 = Die(value: 5, isHeld: true);

      expect(die1, equals(die2));
      expect(die1.hashCode, equals(die2.hashCode));
      expect(die1, isNot(equals(die3)));
      expect(die1, isNot(equals(die4)));
    });

    test('test_die_copyWith', () {
      final die = Die(value: 2, isHeld: false);

      final updated = die.copyWith(value: 5);
      expect(updated.value, equals(5));
      expect(updated.isHeld, isFalse);

      final held = die.copyWith(isHeld: true);
      expect(held.value, equals(2));
      expect(held.isHeld, isTrue);

      final both = die.copyWith(value: 6, isHeld: true);
      expect(both.value, equals(6));
      expect(both.isHeld, isTrue);

      expect(die.value, equals(2)); // original unchanged
      expect(die.isHeld, isFalse);
    });

    test('toString_returns_expected_format', () {
      final die = Die(value: 3, isHeld: true);
      expect(die.toString(), contains('3'));
      expect(die.toString(), contains('true'));
    });

    test('invalid_value_below_1_throws', () {
      expect(() => Die(value: 0), throwsA(isA<ArgumentError>()));
      expect(() => Die(value: -1), throwsA(isA<ArgumentError>()));
    });

    test('invalid_value_above_6_throws', () {
      expect(() => Die(value: 7), throwsA(isA<ArgumentError>()));
      expect(() => Die(value: 100), throwsA(isA<ArgumentError>()));
    });
  });
}
