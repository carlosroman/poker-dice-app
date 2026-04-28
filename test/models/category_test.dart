import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';

/// Tests for the Category enum and its extensions.
///
/// Verifies:
/// - Display names for all categories
/// - Upper/lower section classification
/// - Index ordering
void main() {
  group('Category Extension Tests', () {
    group('displayName', () {
      test('returns correct name for ones', () {
        expect(Category.ones.displayName, 'Ones');
      });

      test('returns correct name for twos', () {
        expect(Category.twos.displayName, 'Twos');
      });

      test('returns correct name for threes', () {
        expect(Category.threes.displayName, 'Threes');
      });

      test('returns correct name for fours', () {
        expect(Category.fours.displayName, 'Fours');
      });

      test('returns correct name for fives', () {
        expect(Category.fives.displayName, 'Fives');
      });

      test('returns correct name for sixes', () {
        expect(Category.sixes.displayName, 'Sixes');
      });

      test('returns correct name for three of a kind', () {
        expect(Category.threeOfAKind.displayName, 'Three of a Kind');
      });

      test('returns correct name for four of a kind', () {
        expect(Category.fourOfAKind.displayName, 'Four of a Kind');
      });

      test('returns correct name for full house', () {
        expect(Category.fullHouse.displayName, 'Full House');
      });

      test('returns correct name for small straight', () {
        expect(Category.smallStraight.displayName, 'Small Straight');
      });

      test('returns correct name for large straight', () {
        expect(Category.largeStraight.displayName, 'Large Straight');
      });

      test('returns correct name for yatzy', () {
        expect(Category.yatzy.displayName, 'Yatzy');
      });

      test('returns correct name for chance', () {
        expect(Category.chance.displayName, 'Chance');
      });

      test('returns correct name for bonus', () {
        expect(Category.bonus.displayName, 'Bonus');
      });
    });

    group('isUpperSection', () {
      test('returns true for ones', () {
        expect(Category.ones.isUpperSection, true);
      });

      test('returns true for twos', () {
        expect(Category.twos.isUpperSection, true);
      });

      test('returns true for threes', () {
        expect(Category.threes.isUpperSection, true);
      });

      test('returns true for fours', () {
        expect(Category.fours.isUpperSection, true);
      });

      test('returns true for fives', () {
        expect(Category.fives.isUpperSection, true);
      });

      test('returns true for sixes', () {
        expect(Category.sixes.isUpperSection, true);
      });

      test('returns true for bonus', () {
        expect(Category.bonus.isUpperSection, true);
      });

      test('returns false for three of a kind', () {
        expect(Category.threeOfAKind.isUpperSection, false);
      });

      test('returns false for four of a kind', () {
        expect(Category.fourOfAKind.isUpperSection, false);
      });

      test('returns false for full house', () {
        expect(Category.fullHouse.isUpperSection, false);
      });

      test('returns false for small straight', () {
        expect(Category.smallStraight.isUpperSection, false);
      });

      test('returns false for large straight', () {
        expect(Category.largeStraight.isUpperSection, false);
      });

      test('returns false for yatzy', () {
        expect(Category.yatzy.isUpperSection, false);
      });

      test('returns false for chance', () {
        expect(Category.chance.isUpperSection, false);
      });
    });

    group('index', () {
      test('returns 0 for ones', () {
        expect(Category.ones.index, 0);
      });

      test('returns 1 for twos', () {
        expect(Category.twos.index, 1);
      });

      test('returns 2 for threes', () {
        expect(Category.threes.index, 2);
      });

      test('returns 3 for fours', () {
        expect(Category.fours.index, 3);
      });

      test('returns 4 for fives', () {
        expect(Category.fives.index, 4);
      });

      test('returns 5 for sixes', () {
        expect(Category.sixes.index, 5);
      });

      test('returns 6 for three of a kind', () {
        expect(Category.threeOfAKind.index, 6);
      });

      test('returns 7 for four of a kind', () {
        expect(Category.fourOfAKind.index, 7);
      });

      test('returns 8 for full house', () {
        expect(Category.fullHouse.index, 8);
      });

      test('returns 9 for small straight', () {
        expect(Category.smallStraight.index, 9);
      });

      test('returns 10 for large straight', () {
        expect(Category.largeStraight.index, 10);
      });

      test('returns 11 for yatzy', () {
        expect(Category.yatzy.index, 11);
      });

      test('returns 12 for chance', () {
        expect(Category.chance.index, 12);
      });

      test('returns 13 for bonus', () {
        expect(Category.bonus.index, 13);
      });
    });

    group('Category.values', () {
      test('contains all 14 categories', () {
        expect(Category.values.length, 14);
      });

      test('includes all upper section categories', () {
        for (var i = 1; i <= 6; i++) {
          expect(Category.values.contains(Category.values[i - 1]), true);
        }
      });

      test('includes all lower section categories', () {
        expect(Category.values.contains(Category.threeOfAKind), true);
        expect(Category.values.contains(Category.fourOfAKind), true);
        expect(Category.values.contains(Category.fullHouse), true);
        expect(Category.values.contains(Category.smallStraight), true);
        expect(Category.values.contains(Category.largeStraight), true);
        expect(Category.values.contains(Category.yatzy), true);
        expect(Category.values.contains(Category.chance), true);
      });

      test('includes bonus category', () {
        expect(Category.values.contains(Category.bonus), true);
      });
    });
  });
}
