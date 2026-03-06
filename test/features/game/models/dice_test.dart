import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/features/game/models/dice.dart';

void main() {
  group('Dice', () {
    group('Dice value mapping tests', () {
      test('value 0 returns face 9', () {
        final dice = Dice(value: 0);
        expect(dice.getFaceValue(), 9);
      });

      test('value 1 returns face 10', () {
        final dice = Dice(value: 1);
        expect(dice.getFaceValue(), 10);
      });

      test('value 2 returns face J', () {
        final dice = Dice(value: 2);
        expect(dice.getFaceValue(), 'J');
      });

      test('value 3 returns face Q', () {
        final dice = Dice(value: 3);
        expect(dice.getFaceValue(), 'Q');
      });

      test('value 4 returns face K', () {
        final dice = Dice(value: 4);
        expect(dice.getFaceValue(), 'K');
      });

      test('value 5 returns face A', () {
        final dice = Dice(value: 5);
        expect(dice.getFaceValue(), 'A');
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
      test('roll() returns value in range 0-5', () {
        final dice = Dice();
        final rolledDice = dice.roll();
        expect(rolledDice.value, inInclusiveRange(0, 5));
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
        final dice = Dice(value: 0, isHeld: true);
        final rolledDice = dice.roll();
        expect(identical(dice, rolledDice), false);
        expect(dice.value, 0);
        expect(dice.isHeld, true);
        expect(rolledDice.isHeld, true);
      });
    });
  });
}
