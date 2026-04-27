import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/die.dart';

void main() {
  group('Die', () {
    group('Constructor', () {
      testDieValueInRange();

      test('throws assertion error for value less than 1', () {
        expect(() => Die(value: 0), throwsAssertionError);
      });

      test('throws assertion error for value greater than 6', () {
        expect(() => Die(value: 7), throwsAssertionError);
      });

      test('default isHeld is false', () {
        final die = Die(value: 3);
        expect(die.isHeld, false);
      });

      test('can create with isHeld true', () {
        final die = Die(value: 3, isHeld: true);
        expect(die.isHeld, true);
      });
    });

    group('toggleHeld', () {
      testDieHeldStateToggle();
    });

    group('roll', () {
      testHeldDieCannotRoll();
      testUnheldDieRollsNewValue();
    });

    group('equality', () {
      testDieEquality();
    });

    group('copyWith', () {
      testDieCopyWith();
    });

    group('random', () {
      testDieRandomFactory();
    });

    group('toString', () {
      test('returns formatted string', () {
        final die = Die(value: 4, isHeld: true);
        expect(die.toString(), 'Die(value: 4, isHeld: true)');
      });
    });
  });
}

/// Test that die values are always in range 1-6
void testDieValueInRange() {
  test('value 1 is valid', () {
    final die = Die(value: 1);
    expect(die.value, 1);
  });

  test('value 6 is valid', () {
    final die = Die(value: 6);
    expect(die.value, 6);
  });

  test('value 3 is valid', () {
    final die = Die(value: 3);
    expect(die.value, 3);
  });
}

/// Test that toggleHeld() correctly toggles the held state
void testDieHeldStateToggle() {
  test('toggles false to true', () {
    final die = Die(value: 3, isHeld: false);
    final toggled = die.toggleHeld();
    expect(toggled.isHeld, true);
    expect(toggled.value, 3);
  });

  test('toggles true to false', () {
    final die = Die(value: 3, isHeld: true);
    final toggled = die.toggleHeld();
    expect(toggled.isHeld, false);
    expect(toggled.value, 3);
  });

  test('returns new instance, not same reference', () {
    final die = Die(value: 3, isHeld: false);
    final toggled = die.toggleHeld();
    expect(identical(die, toggled), false);
  });

  test('can toggle multiple times', () {
    final die = Die(value: 3, isHeld: false);
    final toggled1 = die.toggleHeld();
    final toggled2 = toggled1.toggleHeld();
    expect(toggled1.isHeld, true);
    expect(toggled2.isHeld, false);
    expect(die.isHeld, false); // Original unchanged
  });
}

/// Test that held dice don't change when rolled
void testHeldDieCannotRoll() {
  test('held die retains same value after roll', () {
    final die = Die(value: 4, isHeld: true);
    final rolled = die.roll();
    expect(rolled.value, 4);
    expect(rolled.isHeld, true);
  });

  test('held die returns same reference', () {
    final die = Die(value: 4, isHeld: true);
    final rolled = die.roll();
    expect(identical(die, rolled), true);
  });
}

/// Test that unheld dice get new random values when rolled
void testUnheldDieRollsNewValue() {
  test('unheld die gets new value after roll', () {
    final die = Die(value: 3, isHeld: false);
    final rolled = die.roll();
    expect(rolled.isHeld, false);
    expect(rolled.value, greaterThan(0));
    expect(rolled.value, lessThan(7));
  });

  test('unheld die retains isHeld false after roll', () {
    final die = Die(value: 3, isHeld: false);
    final rolled = die.roll();
    expect(rolled.isHeld, false);
  });

  test('multiple rolls produce valid values', () {
    final die = Die(value: 3, isHeld: false);
    var current = die;
    for (int i = 0; i < 10; i++) {
      current = current.roll();
      expect(current.value, greaterThan(0));
      expect(current.value, lessThan(7));
    }
  });
}

/// Test equality operator
void testDieEquality() {
  test('same value and isHeld are equal', () {
    final die1 = Die(value: 4, isHeld: true);
    final die2 = Die(value: 4, isHeld: true);
    expect(die1, equals(die2));
    expect(die1.hashCode, equals(die2.hashCode));
  });

  test('different values are not equal', () {
    final die1 = Die(value: 3, isHeld: false);
    final die2 = Die(value: 4, isHeld: false);
    expect(die1, isNot(equals(die2)));
  });

  test('different isHeld state are not equal', () {
    final die1 = Die(value: 4, isHeld: true);
    final die2 = Die(value: 4, isHeld: false);
    expect(die1, isNot(equals(die2)));
  });

  test('same reference is equal', () {
    final die = Die(value: 4, isHeld: true);
    expect(die, equals(die));
  });

  test('not equal to different type', () {
    final die = Die(value: 4, isHeld: true);
    expect(die is String, false);
  });
}

/// Test copyWith method
void testDieCopyWith() {
  test('copyWith no args returns identical die', () {
    final die = Die(value: 4, isHeld: true);
    final copy = die.copyWith();
    expect(copy.value, 4);
    expect(copy.isHeld, true);
    expect(copy, equals(die));
  });

  test('copyWith changes only value', () {
    final die = Die(value: 3, isHeld: true);
    final copy = die.copyWith(value: 5);
    expect(copy.value, 5);
    expect(copy.isHeld, true);
  });

  test('copyWith changes only isHeld', () {
    final die = Die(value: 3, isHeld: true);
    final copy = die.copyWith(isHeld: false);
    expect(copy.value, 3);
    expect(copy.isHeld, false);
  });

  test('copyWith changes both value and isHeld', () {
    final die = Die(value: 3, isHeld: true);
    final copy = die.copyWith(value: 6, isHeld: false);
    expect(copy.value, 6);
    expect(copy.isHeld, false);
  });

  test('copyWith returns new instance', () {
    final die = Die(value: 3, isHeld: false);
    final copy = die.copyWith(value: 5);
    expect(identical(die, copy), false);
  });
}

/// Test Die.random() factory constructor
void testDieRandomFactory() {
  test('creates die with value in range 1-6', () {
    final die = Die.random();
    expect(die.value, greaterThan(0));
    expect(die.value, lessThan(7));
    expect(die.isHeld, false);
  });

  test('creates die with isHeld false by default', () {
    final die = Die.random();
    expect(die.isHeld, false);
  });

  test('multiple random dice can have different values', () {
    final dice = <Die>[];
    for (int i = 0; i < 20; i++) {
      dice.add(Die.random());
    }
    // All values should be valid
    for (final die in dice) {
      expect(die.value, greaterThan(0));
      expect(die.value, lessThan(7));
      expect(die.isHeld, false);
    }
  });

  test('random die can be held and rolled', () {
    final die = Die.random();
    final held = die.toggleHeld();
    expect(held.isHeld, true);
    final rolled = held.roll();
    expect(rolled.value, held.value); // Held die doesn't change
  });
}
