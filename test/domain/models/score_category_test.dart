import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';

void main() {
  group('ScoreSection', () {
    test('has exactly 2 values (Upper and Lower)', () {
      expect(ScoreSection.values.length, equals(2));
      expect(ScoreSection.values, contains(ScoreSection.upper));
      expect(ScoreSection.values, contains(ScoreSection.lower));
    });
  });

  group('ScoreCategory', () {
    test('has exactly 13 values', () {
      expect(ScoreCategory.values.length, equals(13));
    });

    test('has all upper section categories', () {
      expect(ScoreCategory.values, contains(ScoreCategory.aces));
      expect(ScoreCategory.values, contains(ScoreCategory.twos));
      expect(ScoreCategory.values, contains(ScoreCategory.threes));
      expect(ScoreCategory.values, contains(ScoreCategory.fours));
      expect(ScoreCategory.values, contains(ScoreCategory.fives));
      expect(ScoreCategory.values, contains(ScoreCategory.sixes));
    });

    test('has all lower section categories', () {
      expect(ScoreCategory.values, contains(ScoreCategory.threeOfKind));
      expect(ScoreCategory.values, contains(ScoreCategory.fourOfKind));
      expect(ScoreCategory.values, contains(ScoreCategory.fullHouse));
      expect(ScoreCategory.values, contains(ScoreCategory.smallStraight));
      expect(ScoreCategory.values, contains(ScoreCategory.largeStraight));
      expect(ScoreCategory.values, contains(ScoreCategory.yatzy));
      expect(ScoreCategory.values, contains(ScoreCategory.chance));
    });
  });

  group('ScoreCategoryExtension - displayName', () {
    test('returns correct display name for Aces', () {
      expect(ScoreCategory.aces.displayName, equals('Aces'));
    });

    test('returns correct display name for Twos', () {
      expect(ScoreCategory.twos.displayName, equals('Twos'));
    });

    test('returns correct display name for Threes', () {
      expect(ScoreCategory.threes.displayName, equals('Threes'));
    });

    test('returns correct display name for Fours', () {
      expect(ScoreCategory.fours.displayName, equals('Fours'));
    });

    test('returns correct display name for Fives', () {
      expect(ScoreCategory.fives.displayName, equals('Fives'));
    });

    test('returns correct display name for Sixes', () {
      expect(ScoreCategory.sixes.displayName, equals('Sixes'));
    });

    test('returns correct display name for ThreeOfKind', () {
      expect(ScoreCategory.threeOfKind.displayName, equals('Three of a Kind'));
    });

    test('returns correct display name for FourOfKind', () {
      expect(ScoreCategory.fourOfKind.displayName, equals('Four of a Kind'));
    });

    test('returns correct display name for FullHouse', () {
      expect(ScoreCategory.fullHouse.displayName, equals('Full House'));
    });

    test('returns correct display name for SmallStraight', () {
      expect(ScoreCategory.smallStraight.displayName, equals('Small Straight'));
    });

    test('returns correct display name for LargeStraight', () {
      expect(ScoreCategory.largeStraight.displayName, equals('Large Straight'));
    });

    test('returns correct display name for Yatzy', () {
      expect(ScoreCategory.yatzy.displayName, equals('Yatzy'));
    });

    test('returns correct display name for Chance', () {
      expect(ScoreCategory.chance.displayName, equals('Chance'));
    });
  });

  group('ScoreCategoryExtension - section', () {
    group('Upper Section categories', () {
      test('Aces belongs to Upper section', () {
        expect(ScoreCategory.aces.section, equals(ScoreSection.upper));
      });

      test('Twos belongs to Upper section', () {
        expect(ScoreCategory.twos.section, equals(ScoreSection.upper));
      });

      test('Threes belongs to Upper section', () {
        expect(ScoreCategory.threes.section, equals(ScoreSection.upper));
      });

      test('Fours belongs to Upper section', () {
        expect(ScoreCategory.fours.section, equals(ScoreSection.upper));
      });

      test('Fives belongs to Upper section', () {
        expect(ScoreCategory.fives.section, equals(ScoreSection.upper));
      });

      test('Sixes belongs to Upper section', () {
        expect(ScoreCategory.sixes.section, equals(ScoreSection.upper));
      });
    });

    group('Lower Section categories', () {
      test('ThreeOfKind belongs to Lower section', () {
        expect(ScoreCategory.threeOfKind.section, equals(ScoreSection.lower));
      });

      test('FourOfKind belongs to Lower section', () {
        expect(ScoreCategory.fourOfKind.section, equals(ScoreSection.lower));
      });

      test('FullHouse belongs to Lower section', () {
        expect(ScoreCategory.fullHouse.section, equals(ScoreSection.lower));
      });

      test('SmallStraight belongs to Lower section', () {
        expect(ScoreCategory.smallStraight.section, equals(ScoreSection.lower));
      });

      test('LargeStraight belongs to Lower section', () {
        expect(ScoreCategory.largeStraight.section, equals(ScoreSection.lower));
      });

      test('Yatzy belongs to Lower section', () {
        expect(ScoreCategory.yatzy.section, equals(ScoreSection.lower));
      });

      test('Chance belongs to Lower section', () {
        expect(ScoreCategory.chance.section, equals(ScoreSection.lower));
      });
    });
  });

  group('ScoreCategoryExtension - index', () {
    test('returns correct index for Aces (0)', () {
      expect(ScoreCategory.aces.index, equals(0));
    });

    test('returns correct index for Twos (1)', () {
      expect(ScoreCategory.twos.index, equals(1));
    });

    test('returns correct index for Threes (2)', () {
      expect(ScoreCategory.threes.index, equals(2));
    });

    test('returns correct index for Fours (3)', () {
      expect(ScoreCategory.fours.index, equals(3));
    });

    test('returns correct index for Fives (4)', () {
      expect(ScoreCategory.fives.index, equals(4));
    });

    test('returns correct index for Sixes (5)', () {
      expect(ScoreCategory.sixes.index, equals(5));
    });

    test('returns correct index for ThreeOfKind (6)', () {
      expect(ScoreCategory.threeOfKind.index, equals(6));
    });

    test('returns correct index for FourOfKind (7)', () {
      expect(ScoreCategory.fourOfKind.index, equals(7));
    });

    test('returns correct index for FullHouse (8)', () {
      expect(ScoreCategory.fullHouse.index, equals(8));
    });

    test('returns correct index for SmallStraight (9)', () {
      expect(ScoreCategory.smallStraight.index, equals(9));
    });

    test('returns correct index for LargeStraight (10)', () {
      expect(ScoreCategory.largeStraight.index, equals(10));
    });

    test('returns correct index for Yatzy (11)', () {
      expect(ScoreCategory.yatzy.index, equals(11));
    });

    test('returns correct index for Chance (12)', () {
      expect(ScoreCategory.chance.index, equals(12));
    });
  });

  group('ScoreCategoryHelper - getUpperCategories', () {
    test('returns exactly 6 categories', () {
      final upperCategories = ScoreCategoryHelper.getUpperCategories();
      expect(upperCategories.length, equals(6));
    });

    test('returns all upper section categories', () {
      final upperCategories = ScoreCategoryHelper.getUpperCategories();
      expect(upperCategories, contains(ScoreCategory.aces));
      expect(upperCategories, contains(ScoreCategory.twos));
      expect(upperCategories, contains(ScoreCategory.threes));
      expect(upperCategories, contains(ScoreCategory.fours));
      expect(upperCategories, contains(ScoreCategory.fives));
      expect(upperCategories, contains(ScoreCategory.sixes));
    });

    test('does not contain any lower section categories', () {
      final upperCategories = ScoreCategoryHelper.getUpperCategories();
      expect(upperCategories, isNot(contains(ScoreCategory.threeOfKind)));
      expect(upperCategories, isNot(contains(ScoreCategory.fourOfKind)));
      expect(upperCategories, isNot(contains(ScoreCategory.fullHouse)));
      expect(upperCategories, isNot(contains(ScoreCategory.smallStraight)));
      expect(upperCategories, isNot(contains(ScoreCategory.largeStraight)));
      expect(upperCategories, isNot(contains(ScoreCategory.yatzy)));
      expect(upperCategories, isNot(contains(ScoreCategory.chance)));
    });
  });

  group('ScoreCategoryHelper - getLowerCategories', () {
    test('returns exactly 7 categories', () {
      final lowerCategories = ScoreCategoryHelper.getLowerCategories();
      expect(lowerCategories.length, equals(7));
    });

    test('returns all lower section categories', () {
      final lowerCategories = ScoreCategoryHelper.getLowerCategories();
      expect(lowerCategories, contains(ScoreCategory.threeOfKind));
      expect(lowerCategories, contains(ScoreCategory.fourOfKind));
      expect(lowerCategories, contains(ScoreCategory.fullHouse));
      expect(lowerCategories, contains(ScoreCategory.smallStraight));
      expect(lowerCategories, contains(ScoreCategory.largeStraight));
      expect(lowerCategories, contains(ScoreCategory.yatzy));
      expect(lowerCategories, contains(ScoreCategory.chance));
    });

    test('does not contain any upper section categories', () {
      final lowerCategories = ScoreCategoryHelper.getLowerCategories();
      expect(lowerCategories, isNot(contains(ScoreCategory.aces)));
      expect(lowerCategories, isNot(contains(ScoreCategory.twos)));
      expect(lowerCategories, isNot(contains(ScoreCategory.threes)));
      expect(lowerCategories, isNot(contains(ScoreCategory.fours)));
      expect(lowerCategories, isNot(contains(ScoreCategory.fives)));
      expect(lowerCategories, isNot(contains(ScoreCategory.sixes)));
    });
  });

  group('ScoreCategoryHelper - getCategoryIndex', () {
    test('returns correct index for all categories', () {
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.aces),
        equals(0),
      );
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.twos),
        equals(1),
      );
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.threes),
        equals(2),
      );
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.fours),
        equals(3),
      );
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.fives),
        equals(4),
      );
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.sixes),
        equals(5),
      );
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.threeOfKind),
        equals(6),
      );
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.fourOfKind),
        equals(7),
      );
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.fullHouse),
        equals(8),
      );
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.smallStraight),
        equals(9),
      );
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.largeStraight),
        equals(10),
      );
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.yatzy),
        equals(11),
      );
      expect(
        ScoreCategoryHelper.getCategoryIndex(ScoreCategory.chance),
        equals(12),
      );
    });
  });
}
