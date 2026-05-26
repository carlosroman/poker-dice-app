import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/die.dart';
import 'package:poker_dice/models/dice_roll.dart';

void main() {
  group('DiceRoll', () {
    test('test_dice_roll_has_exactly_5_dice', () {
      final roll = DiceRoll();
      expect(roll.dice.length, equals(5));
    });

    test('test_dice_roll_default_rolls_random_dice', () {
      final rolls = List<DiceRoll>.generate(100, (_) => DiceRoll());
      final valueSets = rolls.map((r) => r.getValues().toSet()).toList();
      final uniqueSets = valueSets.toSet().length;
      expect(uniqueSets, greaterThan(1));
    });

    test('test_dice_roll_with_custom_dice', () {
      final dice = [
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
        Die(value: 5),
      ];
      final roll = DiceRoll(dice: dice);
      expect(roll.getValues(), equals([1, 2, 3, 4, 5]));
    });

    test('test_dice_roll_invalid_dice_count_uses_random', () {
      final shortDice = [Die(value: 1), Die(value: 2)];
      final roll = DiceRoll(dice: shortDice);
      expect(roll.dice.length, equals(5));
    });

    test('test_sortedDice_returns_sorted_list', () {
      final dice = [
        Die(value: 5),
        Die(value: 1),
        Die(value: 3),
        Die(value: 2),
        Die(value: 4),
      ];
      final roll = DiceRoll(dice: dice);
      final sorted = roll.sortedDice;
      expect(sorted.map((d) => d.value).toList(), equals([1, 2, 3, 4, 5]));
    });

    test('test_sortedDice_does_not_modify_original', () {
      final dice = [
        Die(value: 5),
        Die(value: 1),
        Die(value: 3),
        Die(value: 2),
        Die(value: 4),
      ];
      final roll = DiceRoll(dice: dice);
      roll.sortedDice;
      expect(roll.getValues(), equals([5, 1, 3, 2, 4]));
    });

    test('test_countOccurrences_counts_correctly', () {
      final dice = [
        Die(value: 1),
        Die(value: 1),
        Die(value: 3),
        Die(value: 1),
        Die(value: 5),
      ];
      final roll = DiceRoll(dice: dice);
      expect(roll.countOccurrences(1), equals(3));
      expect(roll.countOccurrences(3), equals(1));
      expect(roll.countOccurrences(5), equals(1));
      expect(roll.countOccurrences(2), equals(0));
      expect(roll.countOccurrences(6), equals(0));
    });

    test('test_getValues_returns_all_values', () {
      final dice = [
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
      ];
      final roll = DiceRoll(dice: dice);
      expect(roll.getValues(), equals([6, 6, 6, 6, 6]));
    });

    test('test_getHeldIndices_returns_held_indices', () {
      final dice = [
        Die(value: 1, isHeld: true),
        Die(value: 2, isHeld: false),
        Die(value: 3, isHeld: true),
        Die(value: 4, isHeld: false),
        Die(value: 5, isHeld: true),
      ];
      final roll = DiceRoll(dice: dice);
      expect(roll.getHeldIndices(), equals([0, 2, 4]));
    });

    test('test_getHeldIndices_returns_empty_when_none_held', () {
      final dice = List<Die>.generate(5, (_) => Die());
      final roll = DiceRoll(dice: dice);
      expect(roll.getHeldIndices(), isEmpty);
    });

    test('test_rollUnheld_only_rerolls_unheld_dice', () {
      final dice = [
        Die(value: 1, isHeld: true),
        Die(value: 2, isHeld: false),
        Die(value: 3, isHeld: false),
        Die(value: 4, isHeld: true),
        Die(value: 5, isHeld: false),
      ];
      final roll = DiceRoll(dice: dice);
      final newRoll = roll.rollUnheld();

      // Unheld dice should be new instances (not identical to original)
      expect(identical(newRoll.dice[1], dice[1]), isFalse);
      expect(identical(newRoll.dice[2], dice[2]), isFalse);
      expect(identical(newRoll.dice[4], dice[4]), isFalse);
    });

    test('test_rollUnheld_keeps_held_dice_unchanged', () {
      final dice = [
        Die(value: 1, isHeld: true),
        Die(value: 2, isHeld: false),
        Die(value: 3, isHeld: true),
        Die(value: 4, isHeld: false),
        Die(value: 5, isHeld: true),
      ];
      final roll = DiceRoll(dice: dice);
      final newRoll = roll.rollUnheld();

      expect(newRoll.dice[0].value, equals(1));
      expect(newRoll.dice[0].isHeld, isTrue);
      expect(newRoll.dice[2].value, equals(3));
      expect(newRoll.dice[2].isHeld, isTrue);
      expect(newRoll.dice[4].value, equals(5));
      expect(newRoll.dice[4].isHeld, isTrue);
    });

    test('test_rollUnheld_all_unheld_rerolls_all', () {
      final dice = List<Die>.generate(5, (_) => Die(value: 1));
      final roll = DiceRoll(dice: dice);
      final newRoll = roll.rollUnheld();
      expect(newRoll.getValues(), isNot(equals([1, 1, 1, 1, 1])));
    });

    test('test_rollUnheld_all_held_keeps_all', () {
      final dice = [
        Die(value: 1, isHeld: true),
        Die(value: 2, isHeld: true),
        Die(value: 3, isHeld: true),
        Die(value: 4, isHeld: true),
        Die(value: 5, isHeld: true),
      ];
      final roll = DiceRoll(dice: dice);
      final newRoll = roll.rollUnheld();
      expect(newRoll.getValues(), equals([1, 2, 3, 4, 5]));
    });

    test('test_dice_roll_equality', () {
      final dice1 = [
        Die(value: 1, isHeld: true),
        Die(value: 2, isHeld: false),
        Die(value: 3, isHeld: true),
        Die(value: 4, isHeld: false),
        Die(value: 5, isHeld: true),
      ];
      final dice2 = [
        Die(value: 1, isHeld: true),
        Die(value: 2, isHeld: false),
        Die(value: 3, isHeld: true),
        Die(value: 4, isHeld: false),
        Die(value: 5, isHeld: true),
      ];
      final dice3 = [
        Die(value: 1, isHeld: false),
        Die(value: 2, isHeld: false),
        Die(value: 3, isHeld: true),
        Die(value: 4, isHeld: false),
        Die(value: 5, isHeld: true),
      ];

      final roll1 = DiceRoll(dice: dice1);
      final roll2 = DiceRoll(dice: dice2);
      final roll3 = DiceRoll(dice: dice3);

      expect(roll1, equals(roll2));
      expect(roll1.hashCode, equals(roll2.hashCode));
      expect(roll1, isNot(equals(roll3)));
    });

    test('test_copyWith_returns_new_roll', () {
      final dice = [
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
        Die(value: 5),
      ];
      final roll = DiceRoll(dice: dice);
      final newDice = [
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
      ];
      final updated = roll.copyWith(dice: newDice);
      expect(updated.getValues(), equals([6, 6, 6, 6, 6]));
      expect(roll.getValues(), equals([1, 2, 3, 4, 5]));
    });

    test('test_copyWith_null_keeps_original', () {
      final dice = [
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
        Die(value: 5),
      ];
      final roll = DiceRoll(dice: dice);
      final updated = roll.copyWith();
      expect(updated.getValues(), equals([1, 2, 3, 4, 5]));
    });

    test('test_toString_contains_dice_info', () {
      final dice = [
        Die(value: 3, isHeld: true),
        Die(value: 5, isHeld: false),
        Die(value: 1, isHeld: false),
        Die(value: 4, isHeld: true),
        Die(value: 2, isHeld: false),
      ];
      final roll = DiceRoll(dice: dice);
      final str = roll.toString();
      expect(str, contains('DiceRoll'));
      expect(str, contains('3'));
      expect(str, contains('true'));
    });

    test('test_dice_list_is_unmodifiable', () {
      final roll = DiceRoll();
      expect(() => roll.dice.add(Die()), throwsA(isA<UnsupportedError>()));
    });
  });
}
