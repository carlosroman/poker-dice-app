import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';

void main() {
  group('ScoreCategory', () {
    group('enum values', () {
      test('all enum values exist', () {
        expect(ScoreCategory.values.length, equals(13));
        expect(ScoreCategory.values.contains(ScoreCategory.aces), isTrue);
        expect(ScoreCategory.values.contains(ScoreCategory.twos), isTrue);
        expect(ScoreCategory.values.contains(ScoreCategory.threes), isTrue);
        expect(ScoreCategory.values.contains(ScoreCategory.fours), isTrue);
        expect(ScoreCategory.values.contains(ScoreCategory.fives), isTrue);
        expect(ScoreCategory.values.contains(ScoreCategory.sixes), isTrue);
        expect(
          ScoreCategory.values.contains(ScoreCategory.threeOfKind),
          isTrue,
        );
        expect(ScoreCategory.values.contains(ScoreCategory.fourOfKind), isTrue);
        expect(ScoreCategory.values.contains(ScoreCategory.fullHouse), isTrue);
        expect(
          ScoreCategory.values.contains(ScoreCategory.smallStraight),
          isTrue,
        );
        expect(
          ScoreCategory.values.contains(ScoreCategory.largeStraight),
          isTrue,
        );
        expect(ScoreCategory.values.contains(ScoreCategory.yatzy), isTrue);
        expect(ScoreCategory.values.contains(ScoreCategory.chance), isTrue);
      });
    });

    group('displayName', () {
      test('aces has correct display name', () {
        expect(ScoreCategory.aces.displayName, equals('1'));
      });

      test('twos has correct display name', () {
        expect(ScoreCategory.twos.displayName, equals('2'));
      });

      test('threes has correct display name', () {
        expect(ScoreCategory.threes.displayName, equals('3'));
      });

      test('fours has correct display name', () {
        expect(ScoreCategory.fours.displayName, equals('4'));
      });

      test('fives has correct display name', () {
        expect(ScoreCategory.fives.displayName, equals('5'));
      });

      test('sixes has correct display name', () {
        expect(ScoreCategory.sixes.displayName, equals('6'));
      });

      test('threeOfKind has correct display name', () {
        expect(ScoreCategory.threeOfKind.displayName, equals('3x'));
      });

      test('fourOfKind has correct display name', () {
        expect(ScoreCategory.fourOfKind.displayName, equals('4x'));
      });

      test('fullHouse has correct display name', () {
        expect(ScoreCategory.fullHouse.displayName, equals('House'));
      });

      test('smallStraight has correct display name', () {
        expect(ScoreCategory.smallStraight.displayName, equals('small'));
      });

      test('largeStraight has correct display name', () {
        expect(ScoreCategory.largeStraight.displayName, equals('large'));
      });

      test('yatzy has correct display name', () {
        expect(ScoreCategory.yatzy.displayName, equals('Yatzy'));
      });

      test('chance has correct display name', () {
        expect(ScoreCategory.chance.displayName, equals('?'));
      });
    });

    group('section', () {
      test('aces belongs to Minor section', () {
        expect(ScoreCategory.aces.section, equals(ScoreSection.minor));
      });

      test('twos belongs to Minor section', () {
        expect(ScoreCategory.twos.section, equals(ScoreSection.minor));
      });

      test('threes belongs to Minor section', () {
        expect(ScoreCategory.threes.section, equals(ScoreSection.minor));
      });

      test('fours belongs to Minor section', () {
        expect(ScoreCategory.fours.section, equals(ScoreSection.minor));
      });

      test('fives belongs to Minor section', () {
        expect(ScoreCategory.fives.section, equals(ScoreSection.minor));
      });

      test('sixes belongs to Minor section', () {
        expect(ScoreCategory.sixes.section, equals(ScoreSection.minor));
      });

      test('threeOfKind belongs to Major section', () {
        expect(ScoreCategory.threeOfKind.section, equals(ScoreSection.major));
      });

      test('fourOfKind belongs to Major section', () {
        expect(ScoreCategory.fourOfKind.section, equals(ScoreSection.major));
      });

      test('fullHouse belongs to Major section', () {
        expect(ScoreCategory.fullHouse.section, equals(ScoreSection.major));
      });

      test('smallStraight belongs to Major section', () {
        expect(ScoreCategory.smallStraight.section, equals(ScoreSection.major));
      });

      test('largeStraight belongs to Major section', () {
        expect(ScoreCategory.largeStraight.section, equals(ScoreSection.major));
      });

      test('yatzy belongs to Major section', () {
        expect(ScoreCategory.yatzy.section, equals(ScoreSection.major));
      });

      test('chance belongs to Major section', () {
        expect(ScoreCategory.chance.section, equals(ScoreSection.major));
      });
    });

    group('Minor section', () {
      test('has exactly 6 categories', () {
        final minorCategories = ScoreCategory.values.where(
          (category) => category.section == ScoreSection.minor,
        );
        expect(minorCategories.length, equals(6));
      });

      test('contains only Aces through Sixes', () {
        final minorCategories = ScoreCategory.values
            .where((category) => category.section == ScoreSection.minor)
            .toList();

        expect(minorCategories, contains(ScoreCategory.aces));
        expect(minorCategories, contains(ScoreCategory.twos));
        expect(minorCategories, contains(ScoreCategory.threes));
        expect(minorCategories, contains(ScoreCategory.fours));
        expect(minorCategories, contains(ScoreCategory.fives));
        expect(minorCategories, contains(ScoreCategory.sixes));
      });

      test('isMinor returns true for Minor section categories', () {
        expect(ScoreCategory.aces.isMinor, isTrue);
        expect(ScoreCategory.twos.isMinor, isTrue);
        expect(ScoreCategory.threes.isMinor, isTrue);
        expect(ScoreCategory.fours.isMinor, isTrue);
        expect(ScoreCategory.fives.isMinor, isTrue);
        expect(ScoreCategory.sixes.isMinor, isTrue);
      });
    });

    group('Major section', () {
      test('has exactly 7 categories', () {
        final majorCategories = ScoreCategory.values.where(
          (category) => category.section == ScoreSection.major,
        );
        expect(majorCategories.length, equals(7));
      });

      test('contains ThreeOfKind through Chance', () {
        final majorCategories = ScoreCategory.values
            .where((category) => category.section == ScoreSection.major)
            .toList();

        expect(majorCategories, contains(ScoreCategory.threeOfKind));
        expect(majorCategories, contains(ScoreCategory.fourOfKind));
        expect(majorCategories, contains(ScoreCategory.fullHouse));
        expect(majorCategories, contains(ScoreCategory.smallStraight));
        expect(majorCategories, contains(ScoreCategory.largeStraight));
        expect(majorCategories, contains(ScoreCategory.yatzy));
        expect(majorCategories, contains(ScoreCategory.chance));
      });

      test('isMajor returns true for Major section categories', () {
        expect(ScoreCategory.threeOfKind.isMajor, isTrue);
        expect(ScoreCategory.fourOfKind.isMajor, isTrue);
        expect(ScoreCategory.fullHouse.isMajor, isTrue);
        expect(ScoreCategory.smallStraight.isMajor, isTrue);
        expect(ScoreCategory.largeStraight.isMajor, isTrue);
        expect(ScoreCategory.yatzy.isMajor, isTrue);
        expect(ScoreCategory.chance.isMajor, isTrue);
      });
    });

    group('complementary properties', () {
      test('isMinor and isMajor are mutually exclusive', () {
        for (final category in ScoreCategory.values) {
          expect(
            category.isMinor && category.isMajor,
            isFalse,
            reason: '${category.displayName} should not be in both sections',
          );
        }
      });

      test('every category is either Minor or Major', () {
        for (final category in ScoreCategory.values) {
          expect(
            category.isMinor || category.isMajor,
            isTrue,
            reason: '${category.displayName} must belong to a section',
          );
        }
      });
    });
  });
}
