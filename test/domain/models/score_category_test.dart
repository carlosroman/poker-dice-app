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
        expect(ScoreCategory.aces.displayName, equals('Aces'));
      });

      test('twos has correct display name', () {
        expect(ScoreCategory.twos.displayName, equals('Twos'));
      });

      test('threes has correct display name', () {
        expect(ScoreCategory.threes.displayName, equals('Threes'));
      });

      test('fours has correct display name', () {
        expect(ScoreCategory.fours.displayName, equals('Fours'));
      });

      test('fives has correct display name', () {
        expect(ScoreCategory.fives.displayName, equals('Fives'));
      });

      test('sixes has correct display name', () {
        expect(ScoreCategory.sixes.displayName, equals('Sixes'));
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
      test('aces belongs to Upper section', () {
        expect(ScoreCategory.aces.section, equals(ScoreSection.upper));
      });

      test('twos belongs to Upper section', () {
        expect(ScoreCategory.twos.section, equals(ScoreSection.upper));
      });

      test('threes belongs to Upper section', () {
        expect(ScoreCategory.threes.section, equals(ScoreSection.upper));
      });

      test('fours belongs to Upper section', () {
        expect(ScoreCategory.fours.section, equals(ScoreSection.upper));
      });

      test('fives belongs to Upper section', () {
        expect(ScoreCategory.fives.section, equals(ScoreSection.upper));
      });

      test('sixes belongs to Upper section', () {
        expect(ScoreCategory.sixes.section, equals(ScoreSection.upper));
      });

      test('threeOfKind belongs to Lower section', () {
        expect(ScoreCategory.threeOfKind.section, equals(ScoreSection.lower));
      });

      test('fourOfKind belongs to Lower section', () {
        expect(ScoreCategory.fourOfKind.section, equals(ScoreSection.lower));
      });

      test('fullHouse belongs to Lower section', () {
        expect(ScoreCategory.fullHouse.section, equals(ScoreSection.lower));
      });

      test('smallStraight belongs to Lower section', () {
        expect(ScoreCategory.smallStraight.section, equals(ScoreSection.lower));
      });

      test('largeStraight belongs to Lower section', () {
        expect(ScoreCategory.largeStraight.section, equals(ScoreSection.lower));
      });

      test('yatzy belongs to Lower section', () {
        expect(ScoreCategory.yatzy.section, equals(ScoreSection.lower));
      });

      test('chance belongs to Lower section', () {
        expect(ScoreCategory.chance.section, equals(ScoreSection.lower));
      });
    });

    group('Upper section', () {
      test('has exactly 6 categories', () {
        final upperCategories = ScoreCategory.values.where(
          (category) => category.section == ScoreSection.upper,
        );
        expect(upperCategories.length, equals(6));
      });

      test('contains only Aces through Sixes', () {
        final upperCategories = ScoreCategory.values
            .where((category) => category.section == ScoreSection.upper)
            .toList();

        expect(upperCategories, contains(ScoreCategory.aces));
        expect(upperCategories, contains(ScoreCategory.twos));
        expect(upperCategories, contains(ScoreCategory.threes));
        expect(upperCategories, contains(ScoreCategory.fours));
        expect(upperCategories, contains(ScoreCategory.fives));
        expect(upperCategories, contains(ScoreCategory.sixes));
      });

      test('isUpper returns true for Upper section categories', () {
        expect(ScoreCategory.aces.isUpper, isTrue);
        expect(ScoreCategory.twos.isUpper, isTrue);
        expect(ScoreCategory.threes.isUpper, isTrue);
        expect(ScoreCategory.fours.isUpper, isTrue);
        expect(ScoreCategory.fives.isUpper, isTrue);
        expect(ScoreCategory.sixes.isUpper, isTrue);
      });
    });

    group('Lower section', () {
      test('has exactly 7 categories', () {
        final lowerCategories = ScoreCategory.values.where(
          (category) => category.section == ScoreSection.lower,
        );
        expect(lowerCategories.length, equals(7));
      });

      test('contains ThreeOfKind through Chance', () {
        final lowerCategories = ScoreCategory.values
            .where((category) => category.section == ScoreSection.lower)
            .toList();

        expect(lowerCategories, contains(ScoreCategory.threeOfKind));
        expect(lowerCategories, contains(ScoreCategory.fourOfKind));
        expect(lowerCategories, contains(ScoreCategory.fullHouse));
        expect(lowerCategories, contains(ScoreCategory.smallStraight));
        expect(lowerCategories, contains(ScoreCategory.largeStraight));
        expect(lowerCategories, contains(ScoreCategory.yatzy));
        expect(lowerCategories, contains(ScoreCategory.chance));
      });

      test('isLower returns true for Lower section categories', () {
        expect(ScoreCategory.threeOfKind.isLower, isTrue);
        expect(ScoreCategory.fourOfKind.isLower, isTrue);
        expect(ScoreCategory.fullHouse.isLower, isTrue);
        expect(ScoreCategory.smallStraight.isLower, isTrue);
        expect(ScoreCategory.largeStraight.isLower, isTrue);
        expect(ScoreCategory.yatzy.isLower, isTrue);
        expect(ScoreCategory.chance.isLower, isTrue);
      });
    });

    group('complementary properties', () {
      test('isUpper and isLower are mutually exclusive', () {
        for (final category in ScoreCategory.values) {
          expect(
            category.isUpper && category.isLower,
            isFalse,
            reason: '${category.displayName} should not be in both sections',
          );
        }
      });

      test('every category is either Upper or Lower', () {
        for (final category in ScoreCategory.values) {
          expect(
            category.isUpper || category.isLower,
            isTrue,
            reason: '${category.displayName} must belong to a section',
          );
        }
      });
    });
  });
}
