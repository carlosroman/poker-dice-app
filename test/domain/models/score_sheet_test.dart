import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/domain/models/score_sheet.dart';

void main() {
  group('ScoreSheet', () {
    // Test dice values for consistent testing
    final yatzyDice = [5, 5, 5, 5, 5];
    final threeOfKindDice = [3, 3, 3, 1, 2];
    final fourOfKindDice = [4, 4, 4, 4, 1];
    final fullHouseDice = [2, 2, 2, 5, 5];
    final smallStraightDice = [1, 2, 3, 4, 6];
    final largeStraightDice = [1, 2, 3, 4, 5];

    group('Initialization', () {
      test('creates empty score sheet with empty scores map', () {
        final sheet = ScoreSheet();
        expect(sheet.scores, isEmpty);
        expect(sheet.yatzyCount, 0);
      });

      test('creates score sheet with initial scores', () {
        final initialScores = {ScoreCategory.aces: 5, ScoreCategory.twos: null};
        final sheet = ScoreSheet(scores: initialScores);
        expect(sheet.scores[ScoreCategory.aces], 5);
        expect(sheet.scores[ScoreCategory.twos], null);
      });

      test('creates score sheet with initial yatzy count', () {
        const initialYatzyCount = 3;
        final sheet = ScoreSheet(yatzyCount: initialYatzyCount);
        expect(sheet.yatzyCount, initialYatzyCount);
      });
    });

    group('Scoring individual categories', () {
      test('scores Aces correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.aces, [1, 1, 2, 3, 4]);
        expect(scoredSheet.scores[ScoreCategory.aces], 2);
      });

      test('scores Twos correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.twos, [2, 2, 2, 3, 4]);
        expect(scoredSheet.scores[ScoreCategory.twos], 6);
      });

      test('scores Threes correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.threes, [3, 3, 1, 2, 4]);
        expect(scoredSheet.scores[ScoreCategory.threes], 6);
      });

      test('scores Fours correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.fours, [4, 4, 4, 1, 2]);
        expect(scoredSheet.scores[ScoreCategory.fours], 12);
      });

      test('scores Fives correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.fives, [5, 5, 1, 2, 3]);
        expect(scoredSheet.scores[ScoreCategory.fives], 10);
      });

      test('scores Sixes correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.sixes, [6, 6, 6, 6, 1]);
        expect(scoredSheet.scores[ScoreCategory.sixes], 24);
      });

      test('scores Three of a Kind correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(
          ScoreCategory.threeOfKind,
          threeOfKindDice,
        );
        expect(scoredSheet.scores[ScoreCategory.threeOfKind], 12);
      });

      test('scores Three of a Kind returns 0 when not achieved', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.threeOfKind, [
          1,
          2,
          3,
          4,
          5,
        ]);
        expect(scoredSheet.scores[ScoreCategory.threeOfKind], 0);
      });

      test('scores Four of a Kind correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(
          ScoreCategory.fourOfKind,
          fourOfKindDice,
        );
        expect(scoredSheet.scores[ScoreCategory.fourOfKind], 17);
      });

      test('scores Four of a Kind returns 0 when not achieved', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.fourOfKind, [
          1,
          2,
          3,
          4,
          5,
        ]);
        expect(scoredSheet.scores[ScoreCategory.fourOfKind], 0);
      });

      test('scores Full House correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.fullHouse, fullHouseDice);
        expect(scoredSheet.scores[ScoreCategory.fullHouse], 25);
      });

      test('scores Full House returns 0 when not achieved', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.fullHouse, [
          1,
          2,
          3,
          4,
          5,
        ]);
        expect(scoredSheet.scores[ScoreCategory.fullHouse], 0);
      });

      test('scores Small Straight correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(
          ScoreCategory.smallStraight,
          smallStraightDice,
        );
        expect(scoredSheet.scores[ScoreCategory.smallStraight], 30);
      });

      test('scores Small Straight returns 0 when not achieved', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.smallStraight, [
          1,
          1,
          2,
          2,
          3,
        ]);
        expect(scoredSheet.scores[ScoreCategory.smallStraight], 0);
      });

      test('scores Large Straight correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(
          ScoreCategory.largeStraight,
          largeStraightDice,
        );
        expect(scoredSheet.scores[ScoreCategory.largeStraight], 40);
      });

      test('scores Large Straight returns 0 when not achieved', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.largeStraight, [
          1,
          2,
          3,
          4,
          4,
        ]);
        expect(scoredSheet.scores[ScoreCategory.largeStraight], 0);
      });

      test('scores Yatzy correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.yatzy, yatzyDice);
        expect(scoredSheet.scores[ScoreCategory.yatzy], 50);
      });

      test('scores Yatzy returns 0 when not achieved', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.yatzy, [1, 2, 3, 4, 5]);
        expect(scoredSheet.scores[ScoreCategory.yatzy], 0);
      });

      test('scores Chance correctly', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.chance, [1, 2, 3, 4, 5]);
        expect(scoredSheet.scores[ScoreCategory.chance], 15);
      });

      test('scores Chance with high values', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.chance, [6, 6, 6, 6, 6]);
        expect(scoredSheet.scores[ScoreCategory.chance], 30);
      });

      test('throws error when dice count is not 5', () {
        final sheet = ScoreSheet();
        expect(
          () => sheet.score(ScoreCategory.aces, [1, 2, 3]),
          throwsArgumentError,
        );
      });
    });

    group('getUpperTotal', () {
      test('returns 0 when no upper categories scored', () {
        final sheet = ScoreSheet();
        expect(sheet.getUpperTotal(), 0);
      });

      test('sums all scored upper categories', () {
        final sheet = ScoreSheet();
        final sheetWithScores = sheet
            .score(ScoreCategory.aces, [1, 1, 1, 2, 3])
            .score(ScoreCategory.twos, [2, 2, 3, 4, 5])
            .score(ScoreCategory.threes, [3, 3, 3, 4, 5]);

        // Aces: 3 (three 1s), Twos: 4 (two 2s), Threes: 9 (three 3s)
        expect(sheetWithScores.getUpperTotal(), 16);
      });

      test('includes zero scores for scored categories', () {
        final sheet = ScoreSheet();
        final sheetWithScores = sheet
            .score(ScoreCategory.aces, [2, 2, 2, 2, 2])
            .score(ScoreCategory.twos, [2, 2, 2, 2, 2]);

        // Aces: 0 (no 1s), Twos: 10 (five 2s)
        expect(sheetWithScores.getUpperTotal(), 10);
      });
    });

    group('getLowerTotal', () {
      test('returns 0 when no lower categories scored', () {
        final sheet = ScoreSheet();
        expect(sheet.getLowerTotal(), 0);
      });

      test('sums all scored lower categories', () {
        final sheet = ScoreSheet();
        final sheetWithScores = sheet
            .score(ScoreCategory.threeOfKind, threeOfKindDice)
            .score(ScoreCategory.fullHouse, fullHouseDice)
            .score(ScoreCategory.chance, [1, 2, 3, 4, 5]);

        expect(sheetWithScores.getLowerTotal(), 12 + 25 + 15);
      });

      test('includes zero scores for scored categories', () {
        final sheet = ScoreSheet();
        final sheetWithScores = sheet
            .score(ScoreCategory.fullHouse, [1, 2, 3, 4, 5])
            .score(ScoreCategory.chance, [1, 2, 3, 4, 5]);

        expect(sheetWithScores.getLowerTotal(), 0 + 15);
      });
    });

    group('getBonus', () {
      test('returns 0 when upper total is below 63', () {
        final sheet = ScoreSheet();
        expect(sheet.getBonus(), 0);
      });

      test('returns 0 when upper total is exactly 62', () {
        final sheet = ScoreSheet();
        // Create a combination that sums to exactly 62
        // 5 aces (5) + 4 twos (8) + 5 threes (15) + 5 fours (20) + 5 fives (25) = 73
        // Let's use: 5 aces (5) + 5 twos (10) + 5 threes (15) + 4 fours (16) + 5 fives (25) = 71
        // Actually: 4 aces (4) + 5 twos (10) + 5 threes (15) + 5 fours (20) + 5 fives (25) = 74
        // For 62: 2 aces (2) + 5 twos (10) + 5 threes (15) + 5 fours (20) + 5 fives (25) = 72
        // For 62: 0 aces (0) + 5 twos (10) + 5 threes (15) + 5 fours (20) + 5 fives (25) = 70
        // For 62: 2 aces (2) + 4 twos (8) + 5 threes (15) + 5 fours (20) + 5 fives (25) = 70
        // For 62: 2 aces (2) + 5 twos (10) + 5 threes (15) + 5 fours (20) + 4 fives (20) = 67
        // For 62: 2 aces (2) + 5 twos (10) + 5 threes (15) + 4 fours (16) + 5 fives (25) = 68
        // For 62: 2 aces (2) + 5 twos (10) + 4 threes (12) + 5 fours (20) + 5 fives (25) = 69
        // For 62: 2 aces (2) + 4 twos (8) + 5 threes (15) + 5 fours (20) + 5 fives (25) = 70
        // For 62: 1 ace (1) + 5 twos (10) + 5 threes (15) + 5 fours (20) + 5 fives (25) = 76
        // For 62: 0 aces (0) + 5 twos (10) + 5 threes (15) + 5 fours (20) + 4 fives (20) = 65
        // For 62: 0 aces (0) + 4 twos (8) + 5 threes (15) + 5 fours (20) + 5 fives (25) = 68
        // For 62: 0 aces (0) + 5 twos (10) + 4 threes (12) + 5 fours (20) + 5 fives (25) = 67
        // For 62: 0 aces (0) + 5 twos (10) + 5 threes (15) + 4 fours (16) + 5 fives (25) = 66
        // For 62: 0 aces (0) + 5 twos (10) + 5 threes (15) + 5 fours (20) + 3 fives (15) = 60
        // For 62: 0 aces (0) + 5 twos (10) + 5 threes (15) + 5 fours (20) + 4 fives (20) = 65
        // Let's compute: 62 = 0 + 10 + 15 + 20 + 17 (impossible for fives)
        // 62 = 2 + 10 + 15 + 20 + 15 = 62 (2 aces, 5 twos, 5 threes, 5 fours, 3 fives)
        final sheetWithScores = sheet
            .score(ScoreCategory.aces, [1, 1, 2, 3, 4])
            .score(ScoreCategory.twos, [2, 2, 2, 2, 2])
            .score(ScoreCategory.threes, [3, 3, 3, 3, 3])
            .score(ScoreCategory.fours, [4, 4, 4, 4, 4])
            .score(ScoreCategory.fives, [5, 5, 5, 1, 2]);

        expect(sheetWithScores.getUpperTotal(), 62);
        expect(sheetWithScores.getBonus(), 0);
      });

      test('returns 35 when upper total is exactly 63', () {
        final sheet = ScoreSheet();
        // Create a combination that sums to exactly 63
        final sheetWithScores = sheet
            .score(ScoreCategory.aces, [1, 1, 1, 1, 1])
            .score(ScoreCategory.twos, [2, 2, 2, 2, 2])
            .score(ScoreCategory.threes, [3, 3, 3, 3, 3])
            .score(ScoreCategory.fours, [4, 4, 4, 4, 4])
            .score(ScoreCategory.fives, [5, 5, 5, 5, 5])
            .score(ScoreCategory.sixes, [6, 6, 6, 6, 6]);

        expect(sheetWithScores.getUpperTotal(), 105);
        expect(sheetWithScores.getBonus(), 35);
      });

      test('returns 35 when upper section qualifies', () {
        final sheet = ScoreSheet();
        final sheetWithScores = sheet
            .score(ScoreCategory.aces, [1, 1, 1, 1, 1])
            .score(ScoreCategory.twos, [2, 2, 2, 2, 2])
            .score(ScoreCategory.threes, [3, 3, 3, 3, 3])
            .score(ScoreCategory.fours, [4, 4, 4, 4, 4])
            .score(ScoreCategory.fives, [5, 5, 5, 5, 5])
            .score(ScoreCategory.sixes, [6, 6, 6, 6, 6]);

        expect(sheetWithScores.getBonus(), 35);
      });
    });

    group('getTotal', () {
      test('returns sum of upper, lower, and bonus', () {
        final sheet = ScoreSheet();
        final sheetWithScores = sheet
            .score(ScoreCategory.aces, [1, 1, 1, 1, 1])
            .score(ScoreCategory.twos, [2, 2, 2, 2, 2])
            .score(ScoreCategory.threes, [3, 3, 3, 3, 3])
            .score(ScoreCategory.fours, [4, 4, 4, 4, 4])
            .score(ScoreCategory.fives, [5, 5, 5, 5, 5])
            .score(ScoreCategory.sixes, [6, 6, 6, 6, 6])
            .score(ScoreCategory.chance, [1, 2, 3, 4, 5]);

        final expectedTotal = 105 + 0 + 35 + 15;
        expect(sheetWithScores.getTotal(), expectedTotal);
      });

      test('includes bonus when upper section qualifies', () {
        final sheet = ScoreSheet();
        final sheetWithScores = sheet
            .score(ScoreCategory.aces, [1, 1, 1, 1, 1])
            .score(ScoreCategory.twos, [2, 2, 2, 2, 2])
            .score(ScoreCategory.threes, [3, 3, 3, 3, 3])
            .score(ScoreCategory.fours, [4, 4, 4, 4, 4])
            .score(ScoreCategory.fives, [5, 5, 5, 5, 5])
            .score(ScoreCategory.sixes, [6, 6, 6, 6, 6])
            .score(ScoreCategory.largeStraight, [1, 2, 3, 4, 5]);

        expect(sheetWithScores.getTotal(), 105 + 40 + 35);
      });

      test('does not include bonus when upper section below threshold', () {
        final sheet = ScoreSheet();
        final sheetWithScores = sheet
            .score(ScoreCategory.aces, [1, 1, 1, 1, 1])
            .score(ScoreCategory.chance, [1, 2, 3, 4, 5]);

        expect(sheetWithScores.getTotal(), 5 + 15 + 0);
      });
    });

    group('isCategoryScored', () {
      test('returns false for unscored category', () {
        final sheet = ScoreSheet();
        expect(sheet.isCategoryScored(ScoreCategory.aces), false);
      });

      test('returns true for scored category with value', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.aces, [1, 1, 1, 2, 3]);
        expect(scoredSheet.isCategoryScored(ScoreCategory.aces), true);
      });

      test('returns true for scored category with zero value', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.aces, [2, 2, 2, 2, 2]);
        expect(scoredSheet.isCategoryScored(ScoreCategory.aces), true);
      });

      test('returns false for category with null score', () {
        final scores = {ScoreCategory.aces: null};
        final sheet = ScoreSheet(scores: scores);
        expect(sheet.isCategoryScored(ScoreCategory.aces), false);
      });
    });

    group('getEmptyCategories', () {
      test('returns all categories when sheet is empty', () {
        final sheet = ScoreSheet();
        final emptyCategories = sheet.getEmptyCategories();
        expect(emptyCategories.length, 13);
        expect(emptyCategories, contains(ScoreCategory.aces));
        expect(emptyCategories, contains(ScoreCategory.chance));
      });

      test('returns only unscored categories', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet
            .score(ScoreCategory.aces, [1, 1, 1, 2, 3])
            .score(ScoreCategory.chance, [1, 2, 3, 4, 5]);

        final emptyCategories = scoredSheet.getEmptyCategories();
        expect(emptyCategories.length, 11);
        expect(emptyCategories, isNot(contains(ScoreCategory.aces)));
        expect(emptyCategories, isNot(contains(ScoreCategory.chance)));
      });

      test('returns empty list when all categories are scored', () {
        final sheet = ScoreSheet();
        var scoredSheet = sheet;

        for (final category in ScoreCategory.values) {
          scoredSheet = scoredSheet.score(category, [1, 2, 3, 4, 5]);
        }

        expect(scoredSheet.getEmptyCategories(), isEmpty);
      });
    });

    group('yatzyCount tracking', () {
      test('starts at 0', () {
        final sheet = ScoreSheet();
        expect(sheet.yatzyCount, 0);
      });

      test('increments when Yatzy is scored successfully', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.yatzy, [4, 4, 4, 4, 4]);
        expect(scoredSheet.yatzyCount, 1);
      });

      test('does not increment when Yatzy is not achieved', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.yatzy, [1, 2, 3, 4, 5]);
        expect(scoredSheet.yatzyCount, 0);
      });

      test('tracks multiple Yatzy rolls', () {
        var sheet = ScoreSheet();
        sheet = sheet.score(ScoreCategory.yatzy, [3, 3, 3, 3, 3]);
        sheet = sheet.score(ScoreCategory.chance, [1, 2, 3, 4, 5]);
        sheet = sheet.score(ScoreCategory.yatzy, [6, 6, 6, 6, 6]);

        expect(sheet.yatzyCount, 2);
      });
    });

    group('copyWith', () {
      test('creates new instance with same values', () {
        final sheet = ScoreSheet(
          scores: {ScoreCategory.aces: 5},
          yatzyCount: 1,
        );
        final copy = sheet.copyWith();

        expect(copy.scores[ScoreCategory.aces], 5);
        expect(copy.yatzyCount, 1);
      });

      test('creates new instance with updated scores', () {
        final sheet = ScoreSheet(scores: {ScoreCategory.aces: 5});
        final copy = sheet.copyWith(scores: {ScoreCategory.twos: 10});

        expect(copy.scores[ScoreCategory.aces], null);
        expect(copy.scores[ScoreCategory.twos], 10);
      });

      test('creates new instance with updated yatzyCount', () {
        final sheet = ScoreSheet(yatzyCount: 1);
        final copy = sheet.copyWith(yatzyCount: 3);

        expect(copy.yatzyCount, 3);
      });

      test('original instance is not modified after copyWith', () {
        final sheet = ScoreSheet(scores: {ScoreCategory.aces: 5});
        final copy = sheet.copyWith(scores: {ScoreCategory.aces: 10});

        expect(sheet.scores[ScoreCategory.aces], 5);
        expect(copy.scores[ScoreCategory.aces], 10);
      });
    });

    group('Immutability', () {
      test('score method returns new instance', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.aces, [1, 1, 1, 2, 3]);

        expect(identical(sheet, scoredSheet), false);
        expect(sheet.scores, isEmpty);
        expect(scoredSheet.scores.isNotEmpty, true);
      });

      test('modifying returned sheet does not affect original', () {
        final sheet = ScoreSheet();
        final scoredSheet = sheet.score(ScoreCategory.aces, [1, 1, 1, 2, 3]);
        final doublyScoredSheet = scoredSheet.score(ScoreCategory.twos, [
          2,
          2,
          2,
          3,
          4,
        ]);

        expect(scoredSheet.scores.length, 1);
        expect(doublyScoredSheet.scores.length, 2);
        expect(sheet.scores, isEmpty);
      });
    });

    group('isComplete', () {
      test('returns false when categories are empty', () {
        final sheet = ScoreSheet();
        expect(sheet.isComplete, false);
      });

      test('returns true when all categories are scored', () {
        final sheet = ScoreSheet();
        var scoredSheet = sheet;

        for (final category in ScoreCategory.values) {
          scoredSheet = scoredSheet.score(category, [1, 2, 3, 4, 5]);
        }

        expect(scoredSheet.isComplete, true);
      });
    });

    group('Equality and hashCode', () {
      test('equal sheets have same hashCode', () {
        final sheet1 = ScoreSheet(
          scores: {ScoreCategory.aces: 5, ScoreCategory.twos: 10},
          yatzyCount: 1,
        );
        final sheet2 = ScoreSheet(
          scores: {ScoreCategory.aces: 5, ScoreCategory.twos: 10},
          yatzyCount: 1,
        );

        expect(sheet1, equals(sheet2));
        expect(sheet1.hashCode, equals(sheet2.hashCode));
      });

      test('different scores result in different equality', () {
        final sheet1 = ScoreSheet(scores: {ScoreCategory.aces: 5});
        final sheet2 = ScoreSheet(scores: {ScoreCategory.aces: 10});

        expect(sheet1, isNot(equals(sheet2)));
      });

      test('different yatzyCount results in different equality', () {
        final sheet1 = ScoreSheet(yatzyCount: 1);
        final sheet2 = ScoreSheet(yatzyCount: 2);

        expect(sheet1, isNot(equals(sheet2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        final sheet = ScoreSheet(
          scores: {ScoreCategory.aces: 5},
          yatzyCount: 1,
        );
        final string = sheet.toString();

        expect(string, contains('ScoreSheet'));
        expect(string, contains('yatzyCount: 1'));
      });
    });
  });
}
