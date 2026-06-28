import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/score_category.dart';

void main() {
  group('ScoreCategory', () {
    test('has 13 categories', () {
      expect(ScoreCategory.values.length, 13);
    });

    group('isUpper', () {
      test('returns true for upper categories', () {
        expect(ScoreCategory.aces.isUpper, isTrue);
        expect(ScoreCategory.twos.isUpper, isTrue);
        expect(ScoreCategory.threes.isUpper, isTrue);
        expect(ScoreCategory.fours.isUpper, isTrue);
        expect(ScoreCategory.fives.isUpper, isTrue);
        expect(ScoreCategory.sixes.isUpper, isTrue);
      });

      test('returns false for lower categories', () {
        expect(ScoreCategory.threeOfAKind.isUpper, isFalse);
        expect(ScoreCategory.fourOfAKind.isUpper, isFalse);
        expect(ScoreCategory.fullHouse.isUpper, isFalse);
        expect(ScoreCategory.smallStraight.isUpper, isFalse);
        expect(ScoreCategory.largeStraight.isUpper, isFalse);
        expect(ScoreCategory.yatzy.isUpper, isFalse);
        expect(ScoreCategory.chance.isUpper, isFalse);
      });
    });

    group('displayName', () {
      test('returns correct display names for all categories', () {
        expect(ScoreCategory.aces.displayName, 'Ones');
        expect(ScoreCategory.twos.displayName, 'Twos');
        expect(ScoreCategory.threes.displayName, 'Threes');
        expect(ScoreCategory.fours.displayName, 'Fours');
        expect(ScoreCategory.fives.displayName, 'Fives');
        expect(ScoreCategory.sixes.displayName, 'Sixes');
        expect(ScoreCategory.threeOfAKind.displayName, 'Three of a Kind');
        expect(ScoreCategory.fourOfAKind.displayName, 'Four of a Kind');
        expect(ScoreCategory.fullHouse.displayName, 'Full House');
        expect(ScoreCategory.smallStraight.displayName, 'Small Straight');
        expect(ScoreCategory.largeStraight.displayName, 'Large Straight');
        expect(ScoreCategory.yatzy.displayName, 'Yatzy');
        expect(ScoreCategory.chance.displayName, 'Chance');
      });
    });

    group('icon', () {
      test('returns valid IconData for all categories', () {
        for (final category in ScoreCategory.values) {
          expect(category.icon, isA<IconData>());
        }
      });

      test('upper categories use dice face icons', () {
        expect(ScoreCategory.aces.icon, Icons.looks_one);
        expect(ScoreCategory.twos.icon, Icons.looks_two);
        expect(ScoreCategory.threes.icon, Icons.looks_3);
        expect(ScoreCategory.fours.icon, Icons.looks_4);
        expect(ScoreCategory.fives.icon, Icons.looks_5);
        expect(ScoreCategory.sixes.icon, Icons.looks_6);
      });

      test('lower categories use thematic icons', () {
        expect(ScoreCategory.fourOfAKind.icon, Icons.star);
        expect(ScoreCategory.fullHouse.icon, Icons.home);
        expect(ScoreCategory.yatzy.icon, Icons.emoji_events);
        expect(ScoreCategory.chance.icon, Icons.casino);
      });
    });

    group('diceValue', () {
      test('returns 1-6 for upper categories', () {
        expect(ScoreCategory.aces.diceValue, 1);
        expect(ScoreCategory.twos.diceValue, 2);
        expect(ScoreCategory.threes.diceValue, 3);
        expect(ScoreCategory.fours.diceValue, 4);
        expect(ScoreCategory.fives.diceValue, 5);
        expect(ScoreCategory.sixes.diceValue, 6);
      });

      test('returns null for lower categories', () {
        expect(ScoreCategory.threeOfAKind.diceValue, isNull);
        expect(ScoreCategory.fourOfAKind.diceValue, isNull);
        expect(ScoreCategory.fullHouse.diceValue, isNull);
        expect(ScoreCategory.smallStraight.diceValue, isNull);
        expect(ScoreCategory.largeStraight.diceValue, isNull);
        expect(ScoreCategory.yatzy.diceValue, isNull);
        expect(ScoreCategory.chance.diceValue, isNull);
      });
    });

    group('categoryOrder', () {
      test('returns sequential order 0-12', () {
        expect(ScoreCategory.aces.categoryOrder, 0);
        expect(ScoreCategory.twos.categoryOrder, 1);
        expect(ScoreCategory.threes.categoryOrder, 2);
        expect(ScoreCategory.fours.categoryOrder, 3);
        expect(ScoreCategory.fives.categoryOrder, 4);
        expect(ScoreCategory.sixes.categoryOrder, 5);
        expect(ScoreCategory.threeOfAKind.categoryOrder, 6);
        expect(ScoreCategory.fourOfAKind.categoryOrder, 7);
        expect(ScoreCategory.fullHouse.categoryOrder, 8);
        expect(ScoreCategory.smallStraight.categoryOrder, 9);
        expect(ScoreCategory.largeStraight.categoryOrder, 10);
        expect(ScoreCategory.yatzy.categoryOrder, 11);
        expect(ScoreCategory.chance.categoryOrder, 12);
      });

      test('categories sort correctly by categoryOrder', () {
        final shuffled = List<ScoreCategory>.from(ScoreCategory.values)
          ..shuffle();

        shuffled.sort((a, b) => a.categoryOrder.compareTo(b.categoryOrder));

        expect(shuffled, equals(ScoreCategory.values));
      });
    });
  });
}
