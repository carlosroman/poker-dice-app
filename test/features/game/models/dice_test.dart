import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/features/game/models/dice.dart';

void main() {
  group('Dice', () {
    group('Dice value tests', () {
      test('dice value is 1-6 after roll', () {
        final dice = Dice();
        final rolledDice = dice.roll();
        expect(rolledDice.value, inInclusiveRange(1, 6));
      });

      test('dice stores correct value 1', () {
        final dice = Dice(value: 1);
        expect(dice.value, 1);
      });

      test('dice stores correct value 6', () {
        final dice = Dice(value: 6);
        expect(dice.value, 6);
      });
    });

    group('Dice hold/unhold toggle tests', () {
      test('initial isHeld is false', () {
        final dice = Dice();
        expect(dice.isHeld, false);
      });

      test('toggleHold() changes state from false to true', () {
        final dice = Dice(isHeld: false);
        final toggledDice = dice.toggleHold();
        expect(toggledDice.isHeld, true);
      });

      test('toggleHold() changes state from true to false', () {
        final dice = Dice(isHeld: true);
        final toggledDice = dice.toggleHold();
        expect(toggledDice.isHeld, false);
      });

      test('toggleHold() returns new instance (immutability)', () {
        final dice = Dice(value: 3, isHeld: false);
        final toggledDice = dice.toggleHold();
        expect(identical(dice, toggledDice), false);
        expect(dice.isHeld, false);
        expect(toggledDice.isHeld, true);
        expect(dice.value, toggledDice.value);
      });
    });

    group('Dice roll randomness tests', () {
      test('roll() returns value in range 1-6', () {
        final dice = Dice();
        final rolledDice = dice.roll();
        expect(rolledDice.value, inInclusiveRange(1, 6));
      });

      test('multiple rolls produce varied results', () {
        final dice = Dice();
        final rolledValues = <int>[];

        for (int i = 0; i < 20; i++) {
          rolledValues.add(dice.roll().value!);
        }

        final uniqueValues = rolledValues.toSet();
        expect(uniqueValues.length, greaterThan(1));
      });

      test('roll() returns new Dice instance (immutability)', () {
        final dice = Dice(value: 3, isHeld: true);
        final rolledDice = dice.roll();
        expect(identical(dice, rolledDice), false);
        expect(dice.value, 3);
        expect(dice.isHeld, true);
        expect(rolledDice.isHeld, true);
      });
    });
  });
}
