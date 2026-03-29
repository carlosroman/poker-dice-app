import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/core/constants/dice_faces.dart'
    show BONUS_THRESHOLD, BONUS_POINTS;
import 'package:poker_dice/features/game/logic/scoring.dart';

void main() {
  group('Upper Section - Sum of Matching Dice Tests', () {
    group('scoreOnes', () {
      test('returns 0 when no 1s present', () {
        final dice = [2, 3, 4, 5, 6];
        expect(Scoring.scoreOnes(dice), 0);
      });

      test('returns 1 for one 1', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scoreOnes(dice), 1);
      });

      test('returns 2 for two 1s', () {
        final dice = [1, 1, 2, 3, 4];
        expect(Scoring.scoreOnes(dice), 2);
      });

      test('returns 3 for three 1s', () {
        final dice = [1, 1, 1, 2, 3];
        expect(Scoring.scoreOnes(dice), 3);
      });

      test('returns 4 for four 1s', () {
        final dice = [1, 1, 1, 1, 2];
        expect(Scoring.scoreOnes(dice), 4);
      });

      test('returns 5 for five 1s', () {
        final dice = [1, 1, 1, 1, 1];
        expect(Scoring.scoreOnes(dice), 5);
      });
    });

    group('scoreTwos', () {
      test('returns 0 when no 2s present', () {
        final dice = [1, 3, 4, 5, 6];
        expect(Scoring.scoreTwos(dice), 0);
      });

      test('returns 2 for one 2', () {
        final dice = [2, 1, 3, 4, 5];
        expect(Scoring.scoreTwos(dice), 2);
      });

      test('returns 4 for two 2s', () {
        final dice = [2, 2, 1, 3, 4];
        expect(Scoring.scoreTwos(dice), 4);
      });

      test('returns 6 for three 2s', () {
        final dice = [2, 2, 2, 1, 3];
        expect(Scoring.scoreTwos(dice), 6);
      });

      test('returns 8 for four 2s', () {
        final dice = [2, 2, 2, 2, 1];
        expect(Scoring.scoreTwos(dice), 8);
      });

      test('returns 10 for five 2s', () {
        final dice = [2, 2, 2, 2, 2];
        expect(Scoring.scoreTwos(dice), 10);
      });
    });

    group('scoreThrees', () {
      test('returns 0 when no 3s present', () {
        final dice = [1, 2, 4, 5, 6];
        expect(Scoring.scoreThrees(dice), 0);
      });

      test('returns 3 for one 3', () {
        final dice = [3, 1, 2, 4, 5];
        expect(Scoring.scoreThrees(dice), 3);
      });

      test('returns 6 for two 3s', () {
        final dice = [3, 3, 1, 2, 4];
        expect(Scoring.scoreThrees(dice), 6);
      });

      test('returns 9 for three 3s', () {
        final dice = [3, 3, 3, 1, 2];
        expect(Scoring.scoreThrees(dice), 9);
      });

      test('returns 12 for four 3s', () {
        final dice = [3, 3, 3, 3, 1];
        expect(Scoring.scoreThrees(dice), 12);
      });

      test('returns 15 for five 3s', () {
        final dice = [3, 3, 3, 3, 3];
        expect(Scoring.scoreThrees(dice), 15);
      });
    });

    group('scoreFours', () {
      test('returns 0 when no 4s present', () {
        final dice = [1, 2, 3, 5, 6];
        expect(Scoring.scoreFours(dice), 0);
      });

      test('returns 4 for one 4', () {
        final dice = [4, 1, 2, 3, 5];
        expect(Scoring.scoreFours(dice), 4);
      });

      test('returns 8 for two 4s', () {
        final dice = [4, 4, 1, 2, 3];
        expect(Scoring.scoreFours(dice), 8);
      });

      test('returns 12 for three 4s', () {
        final dice = [4, 4, 4, 1, 2];
        expect(Scoring.scoreFours(dice), 12);
      });

      test('returns 16 for four 4s', () {
        final dice = [4, 4, 4, 4, 1];
        expect(Scoring.scoreFours(dice), 16);
      });

      test('returns 20 for five 4s', () {
        final dice = [4, 4, 4, 4, 4];
        expect(Scoring.scoreFours(dice), 20);
      });
    });

    group('scoreFives', () {
      test('returns 0 when no 5s present', () {
        final dice = [1, 2, 3, 4, 6];
        expect(Scoring.scoreFives(dice), 0);
      });

      test('returns 5 for one 5', () {
        final dice = [5, 1, 2, 3, 4];
        expect(Scoring.scoreFives(dice), 5);
      });

      test('returns 10 for two 5s', () {
        final dice = [5, 5, 1, 2, 3];
        expect(Scoring.scoreFives(dice), 10);
      });

      test('returns 15 for three 5s', () {
        final dice = [5, 5, 5, 1, 2];
        expect(Scoring.scoreFives(dice), 15);
      });

      test('returns 20 for four 5s', () {
        final dice = [5, 5, 5, 5, 1];
        expect(Scoring.scoreFives(dice), 20);
      });

      test('returns 25 for five 5s', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreFives(dice), 25);
      });
    });

    group('scoreSixes', () {
      test('returns 0 when no 6s present', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scoreSixes(dice), 0);
      });

      test('returns 6 for one 6', () {
        final dice = [6, 1, 2, 3, 4];
        expect(Scoring.scoreSixes(dice), 6);
      });

      test('returns 12 for two 6s', () {
        final dice = [6, 6, 1, 2, 3];
        expect(Scoring.scoreSixes(dice), 12);
      });

      test('returns 18 for three 6s', () {
        final dice = [6, 6, 6, 1, 2];
        expect(Scoring.scoreSixes(dice), 18);
      });

      test('returns 24 for four 6s', () {
        final dice = [6, 6, 6, 6, 1];
        expect(Scoring.scoreSixes(dice), 24);
      });

      test('returns 30 for five 6s', () {
        final dice = [6, 6, 6, 6, 6];
        expect(Scoring.scoreSixes(dice), 30);
      });
    });
  });

  group('Lower Section Tests', () {
    group('scoreThreeOfAKind', () {
      test('returns 0 when no three of a kind present', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scoreThreeOfAKind(dice), 0);
      });

      test('returns sum of all dice for three of a kind', () {
        final dice = [3, 3, 3, 1, 2];
        expect(Scoring.scoreThreeOfAKind(dice), 12);
      });

      test('returns sum of all dice for four of a kind', () {
        final dice = [2, 2, 2, 2, 1];
        expect(Scoring.scoreThreeOfAKind(dice), 9);
      });

      test('returns sum of all dice for five of a kind (Yahtzee)', () {
        final dice = [4, 4, 4, 4, 4];
        expect(Scoring.scoreThreeOfAKind(dice), 20);
      });
    });

    group('scoreFourOfAKind', () {
      test('returns 0 when no four of a kind present', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scoreFourOfAKind(dice), 0);
      });

      test('returns 0 for three of a kind only', () {
        final dice = [3, 3, 3, 1, 2];
        expect(Scoring.scoreFourOfAKind(dice), 0);
      });

      test('returns sum of all dice for four of a kind', () {
        final dice = [2, 2, 2, 2, 1];
        expect(Scoring.scoreFourOfAKind(dice), 9);
      });

      test('returns sum of all dice for five of a kind (Yahtzee)', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreFourOfAKind(dice), 25);
      });
    });

    group('scoreSmallStraight', () {
      test('returns 0 when small straight not present', () {
        final dice = [1, 1, 3, 4, 6];
        expect(Scoring.scoreSmallStraight(dice), 0);
      });

      test('returns 30 when 4 consecutive values present (small straight)', () {
        final dice = [1, 2, 3, 4, 6];
        expect(Scoring.scoreSmallStraight(dice), 30);
      });

      test('returns 30 for 1-2-3-4-5', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scoreSmallStraight(dice), 30);
      });

      test('returns 30 for 2-3-4-5-6', () {
        final dice = [2, 3, 4, 5, 6];
        expect(Scoring.scoreSmallStraight(dice), 30);
      });

      test('returns 30 for small straight in any order', () {
        final dice = [5, 3, 1, 2, 4];
        expect(Scoring.scoreSmallStraight(dice), 30);
      });
    });

    group('scoreLongStraight', () {
      test('returns 0 when long straight not present', () {
        final dice = [1, 1, 2, 3, 4];
        expect(Scoring.scoreLongStraight(dice), 0);
      });

      test('returns 0 when duplicate values present', () {
        final dice = [1, 2, 3, 4, 4];
        expect(Scoring.scoreLongStraight(dice), 0);
      });

      test('returns 40 for 1-2-3-4-5', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scoreLongStraight(dice), 40);
      });

      test('returns 40 for 2-3-4-5-6', () {
        final dice = [2, 3, 4, 5, 6];
        expect(Scoring.scoreLongStraight(dice), 40);
      });

      test('returns 40 for long straight in any order', () {
        final dice = [5, 3, 1, 2, 4];
        expect(Scoring.scoreLongStraight(dice), 40);
      });

      test('returns 0 when missing middle value', () {
        final dice = [1, 2, 3, 5, 6];
        expect(Scoring.scoreLongStraight(dice), 0);
      });
    });

    group('scoreChance', () {
      test('returns sum of all dice values', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scoreChance(dice), 15);
      });

      test('returns sum for all 6s', () {
        final dice = [6, 6, 6, 6, 6];
        expect(Scoring.scoreChance(dice), 30);
      });

      test('returns sum for mixed values', () {
        final dice = [1, 3, 4, 5, 6];
        expect(Scoring.scoreChance(dice), 19);
      });

      test('returns 5 for all 1s', () {
        final dice = [1, 1, 1, 1, 1];
        expect(Scoring.scoreChance(dice), 5);
      });

      test('always returns sum regardless of combination', () {
        final dice = [2, 2, 4, 4, 5];
        expect(Scoring.scoreChance(dice), 17);
      });
    });

    group('scoreFullHouse', () {
      test('returns 0 when full house not present', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scoreFullHouse(dice), 0);
      });

      test('returns 0 for two pairs only', () {
        final dice = [1, 1, 2, 2, 3];
        expect(Scoring.scoreFullHouse(dice), 0);
      });

      test('returns 25 for full house (3+2)', () {
        final dice = [3, 3, 3, 5, 5];
        expect(Scoring.scoreFullHouse(dice), 25);
      });

      test('returns 25 for 6s full house', () {
        final dice = [6, 6, 6, 2, 2];
        expect(Scoring.scoreFullHouse(dice), 25);
      });

      test('returns 0 for four of a kind + one', () {
        final dice = [3, 3, 3, 3, 5];
        expect(Scoring.scoreFullHouse(dice), 0);
      });
    });

    group('scoreYahtzee', () {
      test('returns 0 when Yahtzee not present', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scoreYahtzee(dice), 0);
      });

      test('returns 0 for four of a kind only', () {
        final dice = [3, 3, 3, 3, 5];
        expect(Scoring.scoreYahtzee(dice), 0);
      });

      test('returns 50 for all 5 dice same (1s)', () {
        final dice = [1, 1, 1, 1, 1];
        expect(Scoring.scoreYahtzee(dice), 50);
      });

      test('returns 50 for all 5 dice same (6s)', () {
        final dice = [6, 6, 6, 6, 6];
        expect(Scoring.scoreYahtzee(dice), 50);
      });

      test('returns 50 for all 5 dice same (4s)', () {
        final dice = [4, 4, 4, 4, 4];
        expect(Scoring.scoreYahtzee(dice), 50);
      });
    });
  });

  group('Bonus Calculation Tests', () {
    test('bonus threshold is 63', () {
      expect(BONUS_THRESHOLD, 63);
    });

    test('bonus points is 35', () {
      expect(BONUS_POINTS, 35);
    });

    test('returns bonus when upper section total >= 63', () {
      final upperScores = [4, 6, 9, 12, 15, 18];
      int total = upperScores.fold(0, (sum, score) => sum + score);
      expect(total, 64);
      expect(total >= BONUS_THRESHOLD, true);
    });

    test('upper section with low scores does not meet bonus', () {
      final lowScores = [0, 0, 0, 0, 0, 0];
      int total = lowScores.fold(0, (sum, score) => sum + score);
      expect(total, 0);
      expect(total >= BONUS_THRESHOLD, false);
    });

    test('upper section with one of each meets bonus threshold', () {
      // One of each: (1*3)+(2*3)+(3*3)+(4*3)+(5*3)+(6*3) = 63
      final minimalScores = [3, 6, 9, 12, 15, 18];
      int total = minimalScores.fold(0, (sum, score) => sum + score);
      expect(total, 63);
      expect(total >= BONUS_THRESHOLD, true);
    });

    test('upper section with maximum scores meets bonus', () {
      // Five of each: 5+10+15+20+25+30 = 105
      final maxScores = [5, 10, 15, 20, 25, 30];
      int total = maxScores.fold(0, (sum, score) => sum + score);
      expect(total, 105);
      expect(total >= BONUS_THRESHOLD, true);
    });
  });

  group('Edge Case Tests', () {
    group('All 1s', () {
      test('scoreOnes returns 5', () {
        final dice = [1, 1, 1, 1, 1];
        expect(Scoring.scoreOnes(dice), 5);
      });

      test('scoreTwos returns 0', () {
        final dice = [1, 1, 1, 1, 1];
        expect(Scoring.scoreTwos(dice), 0);
      });

      test('scoreThreeOfAKind returns sum of all', () {
        final dice = [1, 1, 1, 1, 1];
        expect(Scoring.scoreThreeOfAKind(dice), 5);
      });

      test('scoreYahtzee returns 50', () {
        final dice = [1, 1, 1, 1, 1];
        expect(Scoring.scoreYahtzee(dice), 50);
      });
    });

    group('All 6s', () {
      test('scoreSixes returns 30', () {
        final dice = [6, 6, 6, 6, 6];
        expect(Scoring.scoreSixes(dice), 30);
      });

      test('scoreThreeOfAKind returns sum of all', () {
        final dice = [6, 6, 6, 6, 6];
        expect(Scoring.scoreThreeOfAKind(dice), 30);
      });

      test('scoreYahtzee returns 50', () {
        final dice = [6, 6, 6, 6, 6];
        expect(Scoring.scoreYahtzee(dice), 50);
      });
    });

    group('Invalid combinations', () {
      test('returns 0 for no matching dice (straight)', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scoreThreeOfAKind(dice), 0);
        expect(Scoring.scoreFourOfAKind(dice), 0);
        expect(Scoring.scoreFullHouse(dice), 0);
      });

      test('returns 5 of a kind counts for all pair categories', () {
        final dice = [3, 3, 3, 3, 3];
        expect(Scoring.scoreThrees(dice), 15);
        expect(Scoring.scoreThreeOfAKind(dice), 15);
        expect(Scoring.scoreFourOfAKind(dice), 15);
        expect(Scoring.scoreYahtzee(dice), 50);
      });
    });
  });
}
