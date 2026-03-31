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

    group('Dice rollId tests', () {
      test('initial rollId is 0', () {
        final dice = Dice();
        expect(dice.rollId, 0);
      });

      test('rollId increments on each roll', () {
        final dice = Dice();
        final rolled1 = dice.roll();
        final rolled2 = rolled1.roll();
        final rolled3 = rolled2.roll();

        expect(rolled1.rollId, 1);
        expect(rolled2.rollId, 2);
        expect(rolled3.rollId, 3);
      });

      test('toggleHold() preserves rollId', () {
        final dice = Dice(value: 3, rollId: 5);
        final toggledDice = dice.toggleHold();
        expect(toggledDice.rollId, 5);
      });

      test('rollId allows detecting same-value rolls', () {
        final dice = Dice(value: 3, rollId: 1);
        // Simulate a roll that produces the same value
        final rolledDice = dice.copyWith(value: 3, rollId: 2);
        expect(rolledDice.value, dice.value);
        expect(rolledDice.rollId, isNot(equals(dice.rollId)));
      });

      test('copyWith() preserves rollId when not specified', () {
        final dice = Dice(value: 3, isHeld: true, rollId: 5);
        final copiedDice = dice.copyWith(isHeld: false);
        expect(copiedDice.rollId, 5);
        expect(copiedDice.isHeld, false);
        expect(copiedDice.value, 3);
      });

      test('copyWith() can override rollId', () {
        final dice = Dice(value: 3, rollId: 5);
        final copiedDice = dice.copyWith(rollId: 10);
        expect(copiedDice.rollId, 10);
      });

      test('rollId is included in equality', () {
        final dice1 = Dice(value: 3, isHeld: false, rollId: 1);
        final dice2 = Dice(value: 3, isHeld: false, rollId: 2);
        expect(dice1, isNot(equals(dice2)));
      });

      test('rollId is included in hashCode', () {
        final dice1 = Dice(value: 3, isHeld: false, rollId: 1);
        final dice2 = Dice(value: 3, isHeld: false, rollId: 2);
        expect(dice1.hashCode, isNot(equals(dice2.hashCode)));
      });

      test('toJson() includes rollId', () {
        final dice = Dice(value: 3, isHeld: true, rollId: 5);
        final json = dice.toJson();
        expect(json['rollId'], 5);
      });

      test('fromJson() restores rollId', () {
        final json = {'value': 3, 'isHeld': true, 'rollId': 5};
        final dice = Dice.fromJson(json);
        expect(dice.rollId, 5);
      });

      test('fromJson() defaults rollId to 0 when missing', () {
        final json = {'value': 3, 'isHeld': true};
        final dice = Dice.fromJson(json);
        expect(dice.rollId, 0);
      });

      test('toString() includes rollId', () {
        final dice = Dice(value: 3, isHeld: true, rollId: 5);
        final str = dice.toString();
        expect(str, contains('rollId: 5'));
      });
    });
  });
}
