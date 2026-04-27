import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/dice_roll.dart';
import 'package:poker_dice/services/scoring_service.dart';

void main() {
  late ScoringService scoringService;

  setUp(() {
    scoringService = ScoringService();
  });

  group('Upper Section Tests', () {
    group('testOnesScoresCorrectly', () {
      test('should score 0 when no ones present', () {
        final dice = DiceRoll.fromValues([2, 3, 4, 5, 6]);
        expect(scoringService.scoreOnes(dice), 0);
      });

      test('should score 1 when one die shows 1', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreOnes(dice), 1);
      });

      test('should score 3 when three dice show 1', () {
        final dice = DiceRoll.fromValues([1, 1, 1, 5, 6]);
        expect(scoringService.scoreOnes(dice), 3);
      });

      test('should score 5 when all dice show 1', () {
        final dice = DiceRoll.fromValues([1, 1, 1, 1, 1]);
        expect(scoringService.scoreOnes(dice), 5);
      });
    });

    group('testTwosScoresCorrectly', () {
      test('should score 0 when no twos present', () {
        final dice = DiceRoll.fromValues([1, 3, 4, 5, 6]);
        expect(scoringService.scoreTwos(dice), 0);
      });

      test('should score 2 when one die shows 2', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreTwos(dice), 2);
      });

      test('should score 6 when three dice show 2', () {
        final dice = DiceRoll.fromValues([1, 2, 2, 2, 6]);
        expect(scoringService.scoreTwos(dice), 6);
      });

      test('should score 10 when all dice show 2', () {
        final dice = DiceRoll.fromValues([2, 2, 2, 2, 2]);
        expect(scoringService.scoreTwos(dice), 10);
      });
    });

    group('testThreesScoresCorrectly', () {
      test('should score 0 when no threes present', () {
        final dice = DiceRoll.fromValues([1, 2, 4, 5, 6]);
        expect(scoringService.scoreThrees(dice), 0);
      });

      test('should score 3 when one die shows 3', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreThrees(dice), 3);
      });

      test('should score 9 when three dice show 3', () {
        final dice = DiceRoll.fromValues([3, 3, 3, 5, 6]);
        expect(scoringService.scoreThrees(dice), 9);
      });

      test('should score 15 when all dice show 3', () {
        final dice = DiceRoll.fromValues([3, 3, 3, 3, 3]);
        expect(scoringService.scoreThrees(dice), 15);
      });
    });

    group('testFoursScoresCorrectly', () {
      test('should score 0 when no fours present', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 5, 6]);
        expect(scoringService.scoreFours(dice), 0);
      });

      test('should score 4 when one die shows 4', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreFours(dice), 4);
      });

      test('should score 12 when three dice show 4', () {
        final dice = DiceRoll.fromValues([1, 4, 4, 4, 6]);
        expect(scoringService.scoreFours(dice), 12);
      });

      test('should score 20 when all dice show 4', () {
        final dice = DiceRoll.fromValues([4, 4, 4, 4, 4]);
        expect(scoringService.scoreFours(dice), 20);
      });
    });

    group('testFivesScoresCorrectly', () {
      test('should score 0 when no fives present', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 6]);
        expect(scoringService.scoreFives(dice), 0);
      });

      test('should score 5 when one die shows 5', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreFives(dice), 5);
      });

      test('should score 15 when three dice show 5', () {
        final dice = DiceRoll.fromValues([1, 5, 5, 5, 6]);
        expect(scoringService.scoreFives(dice), 15);
      });

      test('should score 25 when all dice show 5', () {
        final dice = DiceRoll.fromValues([5, 5, 5, 5, 5]);
        expect(scoringService.scoreFives(dice), 25);
      });
    });

    group('testSixesScoresCorrectly', () {
      test('should score 0 when no sixes present', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreSixes(dice), 0);
      });

      test('should score 6 when one die shows 6', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 6]);
        expect(scoringService.scoreSixes(dice), 6);
      });

      test('should score 18 when three dice show 6', () {
        final dice = DiceRoll.fromValues([1, 6, 6, 6, 5]);
        expect(scoringService.scoreSixes(dice), 18);
      });

      test('should score 30 when all dice show 6', () {
        final dice = DiceRoll.fromValues([6, 6, 6, 6, 6]);
        expect(scoringService.scoreSixes(dice), 30);
      });
    });

    group('testBonusAwardedAt63', () {
      test('should award 35 bonus when upper section sum is exactly 63', () {
        expect(scoringService.calculateBonus(63), 35);
      });

      test(
        'should award 35 bonus when upper section sum is greater than 63',
        () {
          expect(scoringService.calculateBonus(70), 35);
          expect(scoringService.calculateBonus(80), 35);
        },
      );

      test('should award 0 bonus when upper section sum is less than 63', () {
        expect(scoringService.calculateBonus(62), 0);
        expect(scoringService.calculateBonus(50), 0);
        expect(scoringService.calculateBonus(0), 0);
      });
    });
  });

  group('Lower Section Tests', () {
    group('testThreeOfAKindBasic', () {
      test('should score sum of all dice when exactly 3 of a kind', () {
        final dice = DiceRoll.fromValues([3, 3, 3, 4, 5]);
        expect(scoringService.scoreThreeOfAKind(dice), 18); // 3+3+3+4+5
      });

      test('should score 0 when no three of a kind', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreThreeOfAKind(dice), 0);
      });

      test('should score 0 when only two of a kind', () {
        final dice = DiceRoll.fromValues([2, 2, 3, 4, 5]);
        expect(scoringService.scoreThreeOfAKind(dice), 0);
      });
    });

    group('testThreeOfAKindWithExtraDice', () {
      test('should score sum when 4 of a kind', () {
        final dice = DiceRoll.fromValues([4, 4, 4, 4, 2]);
        expect(scoringService.scoreThreeOfAKind(dice), 18); // 4+4+4+4+2
      });

      test('should score sum when 5 of a kind', () {
        final dice = DiceRoll.fromValues([5, 5, 5, 5, 5]);
        expect(scoringService.scoreThreeOfAKind(dice), 25); // 5+5+5+5+5
      });
    });

    group('testFourOfAKindBasic', () {
      test('should score sum of all dice when exactly 4 of a kind', () {
        final dice = DiceRoll.fromValues([2, 2, 2, 2, 5]);
        expect(scoringService.scoreFourOfAKind(dice), 13); // 2+2+2+2+5
      });

      test('should score 0 when no four of a kind', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreFourOfAKind(dice), 0);
      });

      test('should score 0 when only three of a kind', () {
        final dice = DiceRoll.fromValues([3, 3, 3, 4, 5]);
        expect(scoringService.scoreFourOfAKind(dice), 0);
      });
    });

    group('testFullHouseValid', () {
      test('should score 25 for valid full house (3+2)', () {
        final dice = DiceRoll.fromValues([3, 3, 3, 5, 5]);
        expect(scoringService.scoreFullHouse(dice), 25);
      });

      test('should score 25 for another valid full house', () {
        final dice = DiceRoll.fromValues([1, 1, 1, 6, 6]);
        expect(scoringService.scoreFullHouse(dice), 25);
      });

      test('should score 25 regardless of order', () {
        final dice = DiceRoll.fromValues([2, 4, 2, 4, 4]);
        expect(scoringService.scoreFullHouse(dice), 25);
      });
    });

    group('testFullHouseNotFourPlusOne', () {
      test('should score 0 for four of a kind + one', () {
        final dice = DiceRoll.fromValues([2, 2, 2, 2, 5]);
        expect(scoringService.scoreFullHouse(dice), 0);
      });

      test('should score 0 for five of a kind', () {
        final dice = DiceRoll.fromValues([4, 4, 4, 4, 4]);
        expect(scoringService.scoreFullHouse(dice), 0);
      });
    });

    group('testSmallStraightFourConsecutive', () {
      test('should score 30 for 1-2-3-4-x', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 6]);
        expect(scoringService.scoreSmallStraight(dice), 30);
      });

      test('should score 30 for 2-3-4-5-x', () {
        final dice = DiceRoll.fromValues([2, 3, 4, 5, 1]);
        expect(scoringService.scoreSmallStraight(dice), 30);
      });

      test('should score 30 for 3-4-5-6-x', () {
        final dice = DiceRoll.fromValues([3, 4, 5, 6, 2]);
        expect(scoringService.scoreSmallStraight(dice), 30);
      });

      test('should score 30 for 5 consecutive (also qualifies)', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreSmallStraight(dice), 30);
      });
    });

    group('testLargeStraightFiveConsecutive', () {
      test('should score 40 for 1-2-3-4-5', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreLargeStraight(dice), 40);
      });

      test('should score 40 for 2-3-4-5-6', () {
        final dice = DiceRoll.fromValues([2, 3, 4, 5, 6]);
        expect(scoringService.scoreLargeStraight(dice), 40);
      });

      test('should score 0 for only 4 consecutive', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 6]);
        expect(scoringService.scoreLargeStraight(dice), 0);
      });

      test('should score 0 for non-consecutive', () {
        final dice = DiceRoll.fromValues([1, 2, 4, 5, 6]);
        expect(scoringService.scoreLargeStraight(dice), 0);
      });
    });

    group('testChanceSumAllDice', () {
      test('should sum all dice regardless of combination', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreChance(dice), 15);
      });

      test('should sum all dice for any combination', () {
        final dice = DiceRoll.fromValues([6, 6, 6, 6, 6]);
        expect(scoringService.scoreChance(dice), 30);
      });

      test('should sum all dice for mixed values', () {
        final dice = DiceRoll.fromValues([2, 4, 4, 5, 6]);
        expect(scoringService.scoreChance(dice), 21);
      });
    });

    group('testYatzyFiveOfAKind', () {
      test('should score 50 for all ones', () {
        final dice = DiceRoll.fromValues([1, 1, 1, 1, 1]);
        expect(scoringService.scoreYatzy(dice), 50);
      });

      test('should score 50 for all threes', () {
        final dice = DiceRoll.fromValues([3, 3, 3, 3, 3]);
        expect(scoringService.scoreYatzy(dice), 50);
      });

      test('should score 50 for all sixes', () {
        final dice = DiceRoll.fromValues([6, 6, 6, 6, 6]);
        expect(scoringService.scoreYatzy(dice), 50);
      });

      test('should score 0 when not all dice match', () {
        final dice = DiceRoll.fromValues([1, 1, 1, 1, 2]);
        expect(scoringService.scoreYatzy(dice), 0);
      });

      test('should score 0 for all different values', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreYatzy(dice), 0);
      });
    });
  });

  group('Edge Case Tests', () {
    group('testCategoryReturnsZeroWhenNotQualified', () {
      test('should return 0 for ones when no ones present', () {
        final dice = DiceRoll.fromValues([2, 2, 3, 3, 4]);
        expect(scoringService.scoreOnes(dice), 0);
      });

      test('should return 0 for three of a kind when not qualified', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreThreeOfAKind(dice), 0);
      });

      test('should return 0 for small straight when not qualified', () {
        final dice = DiceRoll.fromValues([1, 1, 3, 3, 5]);
        expect(scoringService.scoreSmallStraight(dice), 0);
      });

      test('should return 0 for yatzy when not qualified', () {
        final dice = DiceRoll.fromValues([2, 2, 3, 3, 3]);
        expect(scoringService.scoreYatzy(dice), 0);
      });
    });

    group('testMultipleCategoriesQualify', () {
      test('yatzy qualifies for three of a kind', () {
        final dice = DiceRoll.fromValues([4, 4, 4, 4, 4]);
        expect(scoringService.scoreYatzy(dice), 50);
        expect(scoringService.scoreThreeOfAKind(dice), 20); // 4+4+4+4+4
        expect(scoringService.scoreFourOfAKind(dice), 20); // 4+4+4+4+4
      });

      test('four of a kind qualifies for three of a kind', () {
        final dice = DiceRoll.fromValues([5, 5, 5, 5, 2]);
        expect(scoringService.scoreThreeOfAKind(dice), 22); // 5+5+5+5+2
        expect(scoringService.scoreFourOfAKind(dice), 22); // 5+5+5+5+2
      });

      test('large straight qualifies for small straight', () {
        final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreSmallStraight(dice), 30);
        expect(scoringService.scoreLargeStraight(dice), 40);
      });
    });

    group('testYatzyAlsoQualifiesForLowerCategories', () {
      test('yatzy of ones qualifies for ones upper section', () {
        final dice = DiceRoll.fromValues([1, 1, 1, 1, 1]);
        expect(scoringService.scoreOnes(dice), 5);
        expect(scoringService.scoreYatzy(dice), 50);
      });

      test('yatzy of sixes qualifies for sixes upper section', () {
        final dice = DiceRoll.fromValues([6, 6, 6, 6, 6]);
        expect(scoringService.scoreSixes(dice), 30);
        expect(scoringService.scoreYatzy(dice), 50);
      });
    });

    group('testSmallStraightWithFiveConsecutive', () {
      test('small straight should score 30 with 5 consecutive dice', () {
        final dice1 = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        expect(scoringService.scoreSmallStraight(dice1), 30);

        final dice2 = DiceRoll.fromValues([2, 3, 4, 5, 6]);
        expect(scoringService.scoreSmallStraight(dice2), 30);
      });
    });

    group('testFullHouseNotFiveOfAKind', () {
      test('five of a kind is not a full house', () {
        final dice = DiceRoll.fromValues([3, 3, 3, 3, 3]);
        expect(scoringService.scoreFullHouse(dice), 0);
        expect(scoringService.scoreYatzy(dice), 50);
      });

      test('four of a kind plus one is not a full house', () {
        final dice = DiceRoll.fromValues([2, 2, 2, 2, 6]);
        expect(scoringService.scoreFullHouse(dice), 0);
        expect(scoringService.scoreFourOfAKind(dice), 14); // 2+2+2+2+6
      });
    });
  });

  group('Score Method Integration Tests', () {
    test('score method routes to correct category methods', () {
      final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);

      expect(scoringService.score(Category.ones, dice), 1);
      expect(scoringService.score(Category.twos, dice), 2);
      expect(scoringService.score(Category.threes, dice), 3);
      expect(scoringService.score(Category.fours, dice), 4);
      expect(scoringService.score(Category.fives, dice), 5);
      expect(scoringService.score(Category.sixes, dice), 0);
      expect(scoringService.score(Category.threeOfAKind, dice), 0);
      expect(scoringService.score(Category.fourOfAKind, dice), 0);
      expect(scoringService.score(Category.fullHouse, dice), 0);
      expect(scoringService.score(Category.smallStraight, dice), 30);
      expect(scoringService.score(Category.largeStraight, dice), 40);
      expect(scoringService.score(Category.yatzy, dice), 0);
      expect(scoringService.score(Category.chance, dice), 15);
    });

    test('score method throws for bonus category', () {
      final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
      expect(
        () => scoringService.score(Category.bonus, dice),
        throwsArgumentError,
      );
    });

    test('score method handles yatzy correctly', () {
      final dice = DiceRoll.fromValues([4, 4, 4, 4, 4]);

      expect(scoringService.score(Category.yatzy, dice), 50);
      expect(scoringService.score(Category.fours, dice), 20);
      expect(scoringService.score(Category.threeOfAKind, dice), 20);
      expect(scoringService.score(Category.fourOfAKind, dice), 20);
      expect(scoringService.score(Category.chance, dice), 20);
    });

    test('score method handles full house correctly', () {
      final dice = DiceRoll.fromValues([2, 2, 2, 5, 5]);

      expect(scoringService.score(Category.fullHouse, dice), 25);
      expect(scoringService.score(Category.fourOfAKind, dice), 0);
      expect(
        scoringService.score(Category.threeOfAKind, dice),
        16,
      ); // 2+2+2+5+5
      expect(scoringService.score(Category.chance, dice), 16);
    });
  });
}
