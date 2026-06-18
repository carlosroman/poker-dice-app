import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/services/dice_roller.dart';

void main() {
  group('DiceRoller', () {
    test('rollDice returns exactly 5 dice', () {
      final roller = DiceRoller();
      final dice = roller.rollDice();

      expect(dice.length, 5);
    });

    test('all dice have values between 1 and 6', () {
      final roller = DiceRoller();

      // Roll multiple times to increase coverage
      for (int i = 0; i < 50; i++) {
        final dice = roller.rollDice();

        for (final die in dice) {
          expect(die.value, greaterThanOrEqualTo(1));
          expect(die.value, lessThanOrEqualTo(6));
        }
      }
    });

    test('all dice have isHeld set to false', () {
      final roller = DiceRoller();
      final dice = roller.rollDice();

      for (final die in dice) {
        expect(die.isHeld, false);
      }
    });

    test('seeded roller produces deterministic results', () {
      final roller1 = DiceRoller(seed: 42);
      final roller2 = DiceRoller(seed: 42);

      final dice1 = roller1.rollDice();
      final dice2 = roller2.rollDice();

      expect(dice1, equals(dice2));
    });

    test('different seeds produce different results', () {
      final roller1 = DiceRoller(seed: 1);
      final roller2 = DiceRoller(seed: 2);

      final dice1 = roller1.rollDice();
      final dice2 = roller2.rollDice();

      expect(dice1, isNot(equals(dice2)));
    });

    test('multiple rolls with same seed produce same sequence', () {
      final roller1 = DiceRoller(seed: 100);
      final roller2 = DiceRoller(seed: 100);

      // First roll
      expect(roller1.rollDice(), equals(roller2.rollDice()));

      // Second roll
      expect(roller1.rollDice(), equals(roller2.rollDice()));

      // Third roll
      expect(roller1.rollDice(), equals(roller2.rollDice()));
    });
  });
}
