import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/die.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/domain/models/score_sheet.dart';

void main() {
  group('ScoreSheet', () {
    // Helper to create a list of 5 dice
    List<Die> createDice(List<int> values) {
      if (values.length != 5) {
        throw ArgumentError('Must provide exactly 5 die values');
      }
      return values.map((v) => Die(value: v)).toList();
    }

    group('Constructor', () {
      test('initializes all categories to null', () {
        final sheet = ScoreSheet();

        for (final category in ScoreCategory.values) {
          expect(
            sheet.scores[category],
            isNull,
            reason: '${category.displayName} should be null initially',
          );
        }
      });

      test('yatzyCount defaults to 0', () {
        final sheet = ScoreSheet();
        expect(sheet.yatzyCount, 0);
      });

      test('yatzyCount can be initialized', () {
        final sheet = ScoreSheet(yatzyCount: 2);
        expect(sheet.yatzyCount, 2);
      });
    });

    group('Upper Section Scoring', () {
      test('aces scores sum of dice showing 1', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 1, 2, 3, 4]);
        final score = sheet.score(ScoreCategory.aces, dice);
        expect(score, 2); // Two 1s = 1 + 1 = 2
        expect(sheet.isCategoryScored(ScoreCategory.aces), isTrue);
      });

      test('twos scores sum of dice showing 2', () {
        final sheet = ScoreSheet();
        final dice = createDice([2, 2, 2, 3, 4]);
        final score = sheet.score(ScoreCategory.twos, dice);
        expect(score, 6); // Three 2s = 2 + 2 + 2 = 6
      });

      test('threes scores sum of dice showing 3', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 3, 3, 4, 5]);
        final score = sheet.score(ScoreCategory.threes, dice);
        expect(score, 6); // Two 3s = 3 + 3 = 6
      });

      test('fours scores sum of dice showing 4', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 2, 4, 4, 6]);
        final score = sheet.score(ScoreCategory.fours, dice);
        expect(score, 8); // Two 4s = 4 + 4 = 8
      });

      test('fives scores sum of dice showing 5', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 5, 5, 5, 6]);
        final score = sheet.score(ScoreCategory.fives, dice);
        expect(score, 15); // Three 5s = 5 + 5 + 5 = 15
      });

      test('sixes scores sum of dice showing 6', () {
        final sheet = ScoreSheet();
        final dice = createDice([6, 6, 3, 4, 5]);
        final score = sheet.score(ScoreCategory.sixes, dice);
        expect(score, 12); // Two 6s = 6 + 6 = 12
      });

      test('upper section returns 0 when no matching dice', () {
        final sheet = ScoreSheet();
        final dice = createDice([2, 3, 4, 5, 6]);
        final score = sheet.score(ScoreCategory.aces, dice);
        expect(score, 0);
      });
    });

    group('Three of a Kind', () {
      test('scores sum of all dice when 3+ match', () {
        final sheet = ScoreSheet();
        final dice = createDice([3, 3, 3, 4, 5]);
        final score = sheet.score(ScoreCategory.threeOfKind, dice);
        expect(score, 18); // 3 + 3 + 3 + 4 + 5 = 18
      });

      test('scores 0 when no 3+ match', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 2, 3, 4, 5]);
        final score = sheet.score(ScoreCategory.threeOfKind, dice);
        expect(score, 0);
      });

      test('scores with 4 of a kind (also qualifies for 3)', () {
        final sheet = ScoreSheet();
        final dice = createDice([2, 2, 2, 2, 6]);
        final score = sheet.score(ScoreCategory.threeOfKind, dice);
        expect(score, 14); // 2 + 2 + 2 + 2 + 6 = 14
      });
    });

    group('Four of a Kind', () {
      test('scores sum of all dice when 4+ match', () {
        final sheet = ScoreSheet();
        final dice = createDice([4, 4, 4, 4, 1]);
        final score = sheet.score(ScoreCategory.fourOfKind, dice);
        expect(score, 17); // 4 + 4 + 4 + 4 + 1 = 17
      });

      test('scores 0 when no 4+ match', () {
        final sheet = ScoreSheet();
        final dice = createDice([3, 3, 3, 5, 6]);
        final score = sheet.score(ScoreCategory.fourOfKind, dice);
        expect(score, 0);
      });
    });

    group('Full House', () {
      test('scores 25 for valid 3+2 combination', () {
        final sheet = ScoreSheet();
        final dice = createDice([3, 3, 3, 5, 5]);
        final score = sheet.score(ScoreCategory.fullHouse, dice);
        expect(score, 25);
      });

      test('scores 25 for another valid 3+2 combination', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 1, 6, 6, 6]);
        final score = sheet.score(ScoreCategory.fullHouse, dice);
        expect(score, 25);
      });

      test('scores 0 for 4+1 combination (not a valid full house)', () {
        final sheet = ScoreSheet();
        final dice = createDice([2, 2, 2, 2, 5]);
        final score = sheet.score(ScoreCategory.fullHouse, dice);
        expect(score, 0);
      });

      test('scores 0 for 5 of a kind (not a valid full house)', () {
        final sheet = ScoreSheet();
        final dice = createDice([4, 4, 4, 4, 4]);
        final score = sheet.score(ScoreCategory.fullHouse, dice);
        expect(score, 0);
      });

      test('scores 0 for no full house pattern', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 2, 3, 4, 5]);
        final score = sheet.score(ScoreCategory.fullHouse, dice);
        expect(score, 0);
      });
    });

    group('Small Straight', () {
      test('scores 30 for 1-2-3-4 pattern', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 2, 3, 4, 6]);
        final score = sheet.score(ScoreCategory.smallStraight, dice);
        expect(score, 30);
      });

      test('scores 30 for 2-3-4-5 pattern', () {
        final sheet = ScoreSheet();
        final dice = createDice([2, 3, 4, 5, 1]);
        final score = sheet.score(ScoreCategory.smallStraight, dice);
        expect(score, 30);
      });

      test('scores 30 for 3-4-5-6 pattern', () {
        final sheet = ScoreSheet();
        final dice = createDice([3, 4, 5, 6, 2]);
        final score = sheet.score(ScoreCategory.smallStraight, dice);
        expect(score, 30);
      });

      test('scores 30 for large straight (also contains small straight)', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 2, 3, 4, 5]);
        final score = sheet.score(ScoreCategory.smallStraight, dice);
        expect(score, 30);
      });

      test('scores 0 for non-consecutive values', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 2, 4, 5, 6]);
        final score = sheet.score(ScoreCategory.smallStraight, dice);
        expect(score, 0);
      });

      test('scores 0 for only 3 consecutive values', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 2, 3, 5, 6]);
        final score = sheet.score(ScoreCategory.smallStraight, dice);
        expect(score, 0);
      });
    });

    group('Large Straight', () {
      test('scores 40 for 1-2-3-4-5 pattern', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 2, 3, 4, 5]);
        final score = sheet.score(ScoreCategory.largeStraight, dice);
        expect(score, 40);
      });

      test('scores 40 for 2-3-4-5-6 pattern', () {
        final sheet = ScoreSheet();
        final dice = createDice([2, 3, 4, 5, 6]);
        final score = sheet.score(ScoreCategory.largeStraight, dice);
        expect(score, 40);
      });

      test('scores 0 for non-consecutive values', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 2, 3, 4, 6]);
        final score = sheet.score(ScoreCategory.largeStraight, dice);
        expect(score, 0);
      });

      test('scores 0 for duplicate values', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 2, 3, 4, 4]);
        final score = sheet.score(ScoreCategory.largeStraight, dice);
        expect(score, 0);
      });
    });

    group('Yatzy', () {
      test('scores 50 for Yatzy with yatzyCount = 0', () {
        final sheet = ScoreSheet(yatzyCount: 0);
        final dice = createDice([5, 5, 5, 5, 5]);
        final score = sheet.score(ScoreCategory.yatzy, dice);
        expect(score, 50);
      });

      test('scores 100 for Yatzy with yatzyCount = 1 (bonus)', () {
        final sheet = ScoreSheet(yatzyCount: 1);
        final dice = createDice([3, 3, 3, 3, 3]);
        final score = sheet.score(ScoreCategory.yatzy, dice);
        expect(score, 100); // 50 + (1 * 50) = 100
      });

      test('scores 150 for Yatzy with yatzyCount = 2 (double bonus)', () {
        final sheet = ScoreSheet(yatzyCount: 2);
        final dice = createDice([6, 6, 6, 6, 6]);
        final score = sheet.score(ScoreCategory.yatzy, dice);
        expect(score, 150); // 50 + (2 * 50) = 150
      });

      test('scores 0 for non-Yatzy', () {
        final sheet = ScoreSheet();
        final dice = createDice([4, 4, 4, 4, 5]);
        final score = sheet.score(ScoreCategory.yatzy, dice);
        expect(score, 0);
      });
    });

    group('Chance', () {
      test('scores sum of all dice', () {
        final sheet = ScoreSheet();
        final dice = createDice([2, 3, 4, 5, 6]);
        final score = sheet.score(ScoreCategory.chance, dice);
        expect(score, 20); // 2 + 3 + 4 + 5 + 6 = 20
      });

      test('scores with all same values', () {
        final sheet = ScoreSheet();
        final dice = createDice([6, 6, 6, 6, 6]);
        final score = sheet.score(ScoreCategory.chance, dice);
        expect(score, 30); // 6 * 5 = 30
      });

      test('scores with all ones', () {
        final sheet = ScoreSheet();
        final dice = createDice([1, 1, 1, 1, 1]);
        final score = sheet.score(ScoreCategory.chance, dice);
        expect(score, 5); // 1 * 5 = 5
      });
    });

    group('Totals', () {
      test('getUpperTotal sums upper section scores', () {
        final sheet = ScoreSheet();
        sheet.score(ScoreCategory.aces, createDice([1, 1, 3, 4, 5]));
        sheet.score(ScoreCategory.twos, createDice([2, 2, 3, 4, 5]));
        expect(sheet.getUpperTotal(), 6); // 2 + 4 = 6
      });

      test('getLowerTotal sums lower section scores', () {
        final sheet = ScoreSheet();
        sheet.score(ScoreCategory.chance, createDice([1, 2, 3, 4, 5]));
        sheet.score(ScoreCategory.yatzy, createDice([4, 4, 4, 4, 4]));
        expect(sheet.getLowerTotal(), 65); // 15 + 50 = 65
      });

      test('getBonus returns 35 when upperTotal >= 63', () {
        final sheet = ScoreSheet();
        // Score enough to reach 63 in upper section
        sheet.score(ScoreCategory.aces, createDice([1, 1, 1, 1, 1])); // 5
        sheet.score(ScoreCategory.twos, createDice([2, 2, 2, 2, 2])); // 10
        sheet.score(ScoreCategory.threes, createDice([3, 3, 3, 3, 3])); // 15
        sheet.score(ScoreCategory.fours, createDice([4, 4, 4, 4, 4])); // 20
        sheet.score(
          ScoreCategory.fives,
          createDice([5, 5, 5, 1, 1]),
        ); // 15 (but only 5+5+5=15)
        // Total so far: 5 + 10 + 15 + 20 + 15 = 65
        expect(sheet.getUpperTotal(), 65);
        expect(sheet.getBonus(), 35);
      });

      test('getBonus returns 0 when upperTotal < 63', () {
        final sheet = ScoreSheet();
        sheet.score(ScoreCategory.aces, createDice([1, 1, 3, 4, 5])); // 2
        sheet.score(ScoreCategory.twos, createDice([2, 2, 3, 4, 5])); // 4
        expect(sheet.getUpperTotal(), 6);
        expect(sheet.getBonus(), 0);
      });

      test('getTotal includes bonus when applicable', () {
        final sheet = ScoreSheet();
        // Score upper section to get bonus
        sheet.score(ScoreCategory.aces, createDice([1, 1, 1, 1, 1])); // 5
        sheet.score(ScoreCategory.twos, createDice([2, 2, 2, 2, 2])); // 10
        sheet.score(ScoreCategory.threes, createDice([3, 3, 3, 3, 3])); // 15
        sheet.score(ScoreCategory.fours, createDice([4, 4, 4, 4, 4])); // 20
        sheet.score(ScoreCategory.fives, createDice([5, 1, 1, 1, 1])); // 5
        sheet.score(ScoreCategory.sixes, createDice([6, 1, 1, 1, 1])); // 6
        // Upper total: 5 + 10 + 15 + 20 + 5 + 6 = 61 (no bonus yet)

        // Score one lower category
        sheet.score(ScoreCategory.chance, createDice([1, 2, 3, 4, 5])); // 15

        expect(sheet.getUpperTotal(), 61);
        expect(sheet.getBonus(), 0);
        expect(sheet.getTotal(), 76); // 61 + 15 + 0 = 76
      });

      test('getTotal includes bonus when upperTotal >= 63', () {
        final sheet = ScoreSheet();
        // Score upper section to get bonus
        sheet.score(ScoreCategory.aces, createDice([1, 1, 1, 1, 1])); // 5
        sheet.score(ScoreCategory.twos, createDice([2, 2, 2, 2, 2])); // 10
        sheet.score(ScoreCategory.threes, createDice([3, 3, 3, 3, 3])); // 15
        sheet.score(ScoreCategory.fours, createDice([4, 4, 4, 4, 4])); // 20
        sheet.score(ScoreCategory.fives, createDice([5, 5, 1, 1, 1])); // 10
        sheet.score(ScoreCategory.sixes, createDice([6, 6, 1, 1, 1])); // 12
        // Upper total: 5 + 10 + 15 + 20 + 10 + 12 = 72

        // Score one lower category
        sheet.score(ScoreCategory.chance, createDice([1, 2, 3, 4, 5])); // 15

        expect(sheet.getUpperTotal(), 72);
        expect(sheet.getBonus(), 35);
        expect(sheet.getTotal(), 122); // 72 + 15 + 35 = 122
      });
    });

    group('isCategoryScored', () {
      test('returns false for unscored category', () {
        final sheet = ScoreSheet();
        expect(sheet.isCategoryScored(ScoreCategory.aces), isFalse);
      });

      test('returns true for scored category', () {
        final sheet = ScoreSheet();
        sheet.score(ScoreCategory.aces, createDice([1, 2, 3, 4, 5]));
        expect(sheet.isCategoryScored(ScoreCategory.aces), isTrue);
      });

      test('returns false for other unscored categories', () {
        final sheet = ScoreSheet();
        sheet.score(ScoreCategory.aces, createDice([1, 2, 3, 4, 5]));
        expect(sheet.isCategoryScored(ScoreCategory.twos), isFalse);
        expect(sheet.isCategoryScored(ScoreCategory.yatzy), isFalse);
      });
    });

    group('getEmptyCategories', () {
      test('returns all categories when sheet is new', () {
        final sheet = ScoreSheet();
        final empty = sheet.getEmptyCategories();
        expect(empty.length, 13);
        expect(empty, containsAll(ScoreCategory.values));
      });

      test('returns remaining categories after some scored', () {
        final sheet = ScoreSheet();
        sheet.score(ScoreCategory.aces, createDice([1, 2, 3, 4, 5]));
        sheet.score(ScoreCategory.chance, createDice([1, 2, 3, 4, 5]));
        final empty = sheet.getEmptyCategories();
        expect(empty.length, 11);
        expect(empty, isNot(contains(ScoreCategory.aces)));
        expect(empty, isNot(contains(ScoreCategory.chance)));
      });

      test('returns empty list when all categories scored', () {
        final sheet = ScoreSheet();
        for (final category in ScoreCategory.values) {
          sheet.score(category, createDice([1, 2, 3, 4, 5]));
        }
        final empty = sheet.getEmptyCategories();
        expect(empty.length, 0);
      });
    });

    group('copyWith', () {
      test('creates new instance with same values', () {
        final sheet = ScoreSheet(yatzyCount: 2);
        sheet.score(ScoreCategory.aces, createDice([1, 1, 3, 4, 5]));

        final copy = sheet.copyWith();

        expect(copy.scores[ScoreCategory.aces], 2);
        expect(copy.yatzyCount, 2);
        expect(copy, isNot(same(sheet)));
      });

      test('creates new instance with updated scores', () {
        final sheet = ScoreSheet();
        sheet.score(ScoreCategory.aces, createDice([1, 1, 3, 4, 5]));

        final newScores = Map<ScoreCategory, int?>.from(sheet.scores);
        newScores[ScoreCategory.twos] = 10;
        final copy = sheet.copyWith(scores: newScores);

        expect(copy.scores[ScoreCategory.aces], 2);
        expect(copy.scores[ScoreCategory.twos], 10);
      });

      test('creates new instance with updated yatzyCount', () {
        final sheet = ScoreSheet(yatzyCount: 1);
        final copy = sheet.copyWith(yatzyCount: 3);

        expect(copy.yatzyCount, 3);
        expect(sheet.yatzyCount, 1); // Original unchanged
      });
    });

    group('Error Handling', () {
      test('throws error when scoring same category twice', () {
        final sheet = ScoreSheet();
        sheet.score(ScoreCategory.aces, createDice([1, 2, 3, 4, 5]));

        expect(
          () => sheet.score(ScoreCategory.aces, createDice([1, 1, 3, 4, 5])),
          throwsStateError,
        );
      });

      test('error message indicates which category is already scored', () {
        final sheet = ScoreSheet();
        sheet.score(ScoreCategory.yatzy, createDice([5, 5, 5, 5, 5]));

        try {
          sheet.score(ScoreCategory.yatzy, createDice([3, 3, 3, 3, 3]));
          fail('Should have thrown StateError');
        } catch (e) {
          expect(e.toString(), contains('Yatzy'));
          expect(e.toString(), contains('already scored'));
        }
      });
    });

    group('yatzyCount', () {
      test('yatzyCount is used for bonus calculation in Yatzy score', () {
        // First Yatzy
        final sheet1 = ScoreSheet(yatzyCount: 0);
        final score1 = sheet1.score(
          ScoreCategory.yatzy,
          createDice([4, 4, 4, 4, 4]),
        );
        expect(score1, 50);

        // Second Yatzy with bonus
        final sheet2 = ScoreSheet(yatzyCount: 1);
        final score2 = sheet2.score(
          ScoreCategory.yatzy,
          createDice([4, 4, 4, 4, 4]),
        );
        expect(score2, 100);
      });
    });
  });
}
