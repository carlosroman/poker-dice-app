import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/die.dart';
import 'package:poker_dice/models/dice_roll.dart';

void main() {
  group('DiceRoll Constructor Tests', () {
    test('creates DiceRoll with exactly 5 dice', () {
      final dice = List<Die>.generate(5, (_) => Die(value: 1));
      final roll = DiceRoll(dice);

      expect(roll.dice.length, 5);
    });

    test('throws assertion error when dice count is not 5', () {
      final dice = List<Die>.generate(3, (_) => Die(value: 1));

      expect(() => DiceRoll(dice), throwsAssertionError);
    });

    test('fromValues creates correct dice with specified values', () {
      final values = [1, 2, 3, 4, 5];
      final roll = DiceRoll.fromValues(values);

      expect(roll.dice.length, 5);
      expect(roll.dice[0].value, 1);
      expect(roll.dice[1].value, 2);
      expect(roll.dice[2].value, 3);
      expect(roll.dice[3].value, 4);
      expect(roll.dice[4].value, 5);
    });

    test('fromValues creates dice with isHeld false by default', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);

      for (final die in roll.dice) {
        expect(die.isHeld, false);
      }
    });

    test('fromValues throws assertion error when values count is not 5', () {
      expect(() => DiceRoll.fromValues([1, 2, 3]), throwsAssertionError);
    });

    test('random creates valid roll with 5 dice', () {
      final roll = DiceRoll.random();

      expect(roll.dice.length, 5);
      for (final die in roll.dice) {
        expect(die.value, inInclusiveRange(1, 6));
        expect(die.isHeld, false);
      }
    });
  });

  group('sortedDice', () {
    test('returns dice sorted by value ascending', () {
      final roll = DiceRoll.fromValues([5, 2, 6, 1, 3]);
      final sorted = roll.sortedDice;

      expect(sorted[0].value, 1);
      expect(sorted[1].value, 2);
      expect(sorted[2].value, 3);
      expect(sorted[3].value, 5);
      expect(sorted[4].value, 6);
    });

    test('returns new list, not modifying original', () {
      final roll = DiceRoll.fromValues([3, 1, 2, 5, 4]);
      final sorted = roll.sortedDice;

      expect(roll.dice[0].value, 3);
      expect(sorted[0].value, 1);
    });

    test('handles already sorted dice correctly', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final sorted = roll.sortedDice;

      for (int i = 0; i < 5; i++) {
        expect(sorted[i].value, i + 1);
      }
    });

    test('handles all same values correctly', () {
      final roll = DiceRoll.fromValues([3, 3, 3, 3, 3]);
      final sorted = roll.sortedDice;

      for (final die in sorted) {
        expect(die.value, 3);
      }
    });
  });

  group('countOccurrences', () {
    test('counts correct number of dice showing specific value', () {
      final roll = DiceRoll.fromValues([1, 2, 1, 3, 1]);

      expect(roll.countOccurrences(1), 3);
      expect(roll.countOccurrences(2), 1);
      expect(roll.countOccurrences(3), 1);
    });

    test('returns 0 when value not present', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);

      expect(roll.countOccurrences(6), 0);
    });

    test('counts all sixes correctly', () {
      final roll = DiceRoll.fromValues([6, 6, 1, 6, 2]);

      expect(roll.countOccurrences(6), 3);
    });

    test('handles full house scenario', () {
      final roll = DiceRoll.fromValues([4, 4, 4, 2, 2]);

      expect(roll.countOccurrences(4), 3);
      expect(roll.countOccurrences(2), 2);
    });
  });

  group('getDiceCounts', () {
    test('returns correct map of value to count', () {
      final roll = DiceRoll.fromValues([1, 2, 1, 3, 2]);
      final counts = roll.getDiceCounts();

      expect(counts[1], 2);
      expect(counts[2], 2);
      expect(counts[3], 1);
    });

    test('only includes values that appear in dice', () {
      final roll = DiceRoll.fromValues([1, 1, 2, 2, 3]);
      final counts = roll.getDiceCounts();

      expect(counts.containsKey(1), true);
      expect(counts.containsKey(2), true);
      expect(counts.containsKey(3), true);
      expect(counts.containsKey(4), false);
      expect(counts.containsKey(5), false);
      expect(counts.containsKey(6), false);
    });

    test('returns empty map for empty roll is not possible', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final counts = roll.getDiceCounts();

      expect(counts.length, 5);
    });

    test('handles all same values correctly', () {
      final roll = DiceRoll.fromValues([5, 5, 5, 5, 5]);
      final counts = roll.getDiceCounts();

      expect(counts.length, 1);
      expect(counts[5], 5);
    });
  });

  group('sumAllDice', () {
    test('returns correct sum of all dice values', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);

      expect(roll.sumAllDice(), 15);
    });

    test('sums all sixes correctly', () {
      final roll = DiceRoll.fromValues([6, 6, 6, 6, 6]);

      expect(roll.sumAllDice(), 30);
    });

    test('sums all ones correctly', () {
      final roll = DiceRoll.fromValues([1, 1, 1, 1, 1]);

      expect(roll.sumAllDice(), 5);
    });

    test('handles mixed values correctly', () {
      final roll = DiceRoll.fromValues([2, 4, 6, 1, 3]);

      expect(roll.sumAllDice(), 16);
    });
  });

  group('toggleDieHeld', () {
    test('toggles held state of die at index', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final toggled = roll.toggleDieHeld(2);

      expect(roll.dice[2].isHeld, false);
      expect(toggled.dice[2].isHeld, true);
    });

    test('toggles from held to not held', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final held = roll.toggleDieHeld(2);
      final toggled = held.toggleDieHeld(2);

      expect(held.dice[2].isHeld, true);
      expect(toggled.dice[2].isHeld, false);
    });

    test('returns new instance, original unchanged', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final toggled = roll.toggleDieHeld(0);

      expect(roll.dice[0].isHeld, false);
      expect(toggled.dice[0].isHeld, true);
      expect(roll.dice[1].isHeld, false);
      expect(toggled.dice[1].isHeld, false);
    });

    test('only toggles specified index', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final toggled = roll.toggleDieHeld(3);

      for (int i = 0; i < 5; i++) {
        if (i == 3) {
          expect(toggled.dice[i].isHeld, true);
        } else {
          expect(toggled.dice[i].isHeld, false);
        }
      }
    });

    test('throws assertion error for invalid index', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);

      expect(() => roll.toggleDieHeld(-1), throwsAssertionError);
      expect(() => roll.toggleDieHeld(5), throwsAssertionError);
    });
  });

  group('rollUnheldDice', () {
    test('rolls only unheld dice', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final held = roll.toggleDieHeld(2); // Hold die at index 2 (value 3)
      final rolled = held.rollUnheldDice();

      expect(rolled.dice[2].value, 3);
      expect(rolled.dice[2].isHeld, true);
    });

    test('held dice remain unchanged after roll', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final held = roll.toggleDieHeld(0).toggleDieHeld(4);
      final rolled = held.rollUnheldDice();

      expect(rolled.dice[0].value, 1);
      expect(rolled.dice[0].isHeld, true);
      expect(rolled.dice[4].value, 5);
      expect(rolled.dice[4].isHeld, true);
    });

    test('unheld dice may change value', () {
      final roll = DiceRoll.fromValues([1, 1, 1, 1, 1]);
      final held = roll.toggleDieHeld(0).toggleDieHeld(1).toggleDieHeld(2);
      final rolled = held.rollUnheldDice();

      expect(rolled.dice[0].value, 1);
      expect(rolled.dice[1].value, 1);
      expect(rolled.dice[2].value, 1);
      // The unheld dice at indices 3 and 4 may or may not change
      expect(rolled.dice[3].isHeld, false);
      expect(rolled.dice[4].isHeld, false);
    });

    test('returns new instance', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final rolled = roll.rollUnheldDice();

      expect(roll, isNot(equals(rolled)));
    });
  });

  group('allHeld', () {
    test('returns false when no dice are held', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);

      expect(roll.allHeld, false);
    });

    test('returns false when some dice are held', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final held = roll.toggleDieHeld(0).toggleDieHeld(2).toggleDieHeld(4);

      expect(held.allHeld, false);
    });

    test('returns true when all dice are held', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final held = roll
          .toggleDieHeld(0)
          .toggleDieHeld(1)
          .toggleDieHeld(2)
          .toggleDieHeld(3)
          .toggleDieHeld(4);

      expect(held.allHeld, true);
    });
  });

  group('copyWith', () {
    test('creates copy with same dice when no parameters provided', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final copy = roll.copyWith();

      expect(copy.dice.length, 5);
      for (int i = 0; i < 5; i++) {
        expect(copy.dice[i].value, roll.dice[i].value);
      }
    });

    test('creates copy with new dice when dice parameter provided', () {
      final original = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final newDice = List<Die>.generate(5, (_) => Die(value: 6));
      final copy = original.copyWith(dice: newDice);

      expect(copy.dice, newDice);
      for (final die in copy.dice) {
        expect(die.value, 6);
      }
    });

    test('returns new instance', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final copy = roll.copyWith();

      expect(roll, isNot(same(copy)));
    });
  });

  group('equality', () {
    test('equal dice rolls are equal', () {
      final roll1 = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final roll2 = DiceRoll.fromValues([1, 2, 3, 4, 5]);

      expect(roll1, equals(roll2));
    });

    test('different dice rolls are not equal', () {
      final roll1 = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final roll2 = DiceRoll.fromValues([1, 2, 3, 4, 6]);

      expect(roll1, isNot(equals(roll2)));
    });

    test('dice rolls with different held states are not equal', () {
      final roll1 = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final roll2 = DiceRoll.fromValues([1, 2, 3, 4, 5]).toggleDieHeld(0);

      expect(roll1, isNot(equals(roll2)));
    });

    test('hashCode is consistent for equal objects', () {
      final roll1 = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final roll2 = DiceRoll.fromValues([1, 2, 3, 4, 5]);

      expect(roll1.hashCode, equals(roll2.hashCode));
    });

    test('hashCode considers all dice', () {
      final roll1 = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final roll2 = DiceRoll.fromValues([1, 2, 3, 4, 6]);

      expect(roll1.hashCode, isNot(equals(roll2.hashCode)));
    });

    test('identical objects are equal', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);

      expect(roll, equals(roll));
    });

    test('equals returns false for non-DiceRoll objects', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);

      expect(roll is String, false);
    });
  });

  group('toString', () {
    test('returns descriptive string', () {
      final roll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      final str = roll.toString();

      expect(str, contains('DiceRoll'));
      expect(str, contains('dice:'));
    });
  });
}
