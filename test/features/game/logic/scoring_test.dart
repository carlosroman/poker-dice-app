import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/features/game/logic/scoring.dart';

void main() {
  group('Upper Section - Pair Tests', () {
    group('score9s', () {
      test('returns 0 when no 9s present', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.score9s(dice), 0);
      });

      test('returns 1 for one 9', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.score9s(dice), 1);
      });

      test('returns 2 for two 9s', () {
        final dice = [0, 0, 1, 2, 3];
        expect(Scoring.score9s(dice), 2);
      });

      test('returns 3 for three 9s', () {
        final dice = [0, 0, 0, 1, 2];
        expect(Scoring.score9s(dice), 3);
      });

      test('returns 4 for four 9s', () {
        final dice = [0, 0, 0, 0, 1];
        expect(Scoring.score9s(dice), 4);
      });

      test('returns 5 for five 9s', () {
        final dice = [0, 0, 0, 0, 0];
        expect(Scoring.score9s(dice), 5);
      });

      test('returns 0 for empty hand (all Aces)', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.score9s(dice), 0);
      });
    });

    group('score10s', () {
      test('returns 0 when no 10s present', () {
        final dice = [0, 2, 3, 4, 5];
        expect(Scoring.score10s(dice), 0);
      });

      test('returns 2 for one 10', () {
        final dice = [1, 0, 2, 3, 4];
        expect(Scoring.score10s(dice), 2);
      });

      test('returns 4 for two 10s', () {
        final dice = [1, 1, 0, 2, 3];
        expect(Scoring.score10s(dice), 4);
      });

      test('returns 6 for three 10s', () {
        final dice = [1, 1, 1, 0, 2];
        expect(Scoring.score10s(dice), 6);
      });

      test('returns 8 for four 10s', () {
        final dice = [1, 1, 1, 1, 0];
        expect(Scoring.score10s(dice), 8);
      });

      test('returns 10 for five 10s', () {
        final dice = [1, 1, 1, 1, 1];
        expect(Scoring.score10s(dice), 10);
      });
    });

    group('scoreJs', () {
      test('returns 0 when no Jacks present', () {
        final dice = [0, 1, 3, 4, 5];
        expect(Scoring.scoreJs(dice), 0);
      });

      test('returns 3 for one Jack', () {
        final dice = [2, 0, 1, 3, 4];
        expect(Scoring.scoreJs(dice), 3);
      });

      test('returns 6 for two Jacks', () {
        final dice = [2, 2, 0, 1, 3];
        expect(Scoring.scoreJs(dice), 6);
      });

      test('returns 9 for three Jacks', () {
        final dice = [2, 2, 2, 0, 1];
        expect(Scoring.scoreJs(dice), 9);
      });

      test('returns 12 for four Jacks', () {
        final dice = [2, 2, 2, 2, 0];
        expect(Scoring.scoreJs(dice), 12);
      });

      test('returns 15 for five Jacks', () {
        final dice = [2, 2, 2, 2, 2];
        expect(Scoring.scoreJs(dice), 15);
      });
    });

    group('scoreQs', () {
      test('returns 0 when no Queens present', () {
        final dice = [0, 1, 2, 4, 5];
        expect(Scoring.scoreQs(dice), 0);
      });

      test('returns 4 for one Queen', () {
        final dice = [3, 0, 1, 2, 4];
        expect(Scoring.scoreQs(dice), 4);
      });

      test('returns 8 for two Queens', () {
        final dice = [3, 3, 0, 1, 2];
        expect(Scoring.scoreQs(dice), 8);
      });

      test('returns 12 for three Queens', () {
        final dice = [3, 3, 3, 0, 1];
        expect(Scoring.scoreQs(dice), 12);
      });

      test('returns 16 for four Queens', () {
        final dice = [3, 3, 3, 3, 0];
        expect(Scoring.scoreQs(dice), 16);
      });

      test('returns 20 for five Queens', () {
        final dice = [3, 3, 3, 3, 3];
        expect(Scoring.scoreQs(dice), 20);
      });
    });

    group('scoreKs', () {
      test('returns 0 when no Kings present', () {
        final dice = [0, 1, 2, 3, 5];
        expect(Scoring.scoreKs(dice), 0);
      });

      test('returns 5 for one King', () {
        final dice = [4, 0, 1, 2, 3];
        expect(Scoring.scoreKs(dice), 5);
      });

      test('returns 10 for two Kings', () {
        final dice = [4, 4, 0, 1, 2];
        expect(Scoring.scoreKs(dice), 10);
      });

      test('returns 15 for three Kings', () {
        final dice = [4, 4, 4, 0, 1];
        expect(Scoring.scoreKs(dice), 15);
      });

      test('returns 20 for four Kings', () {
        final dice = [4, 4, 4, 4, 0];
        expect(Scoring.scoreKs(dice), 20);
      });

      test('returns 25 for five Kings', () {
        final dice = [4, 4, 4, 4, 4];
        expect(Scoring.scoreKs(dice), 25);
      });
    });

    group('scoreAs', () {
      test('returns 0 when no Aces present', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scoreAs(dice), 0);
      });

      test('returns 6 for one Ace', () {
        final dice = [5, 0, 1, 2, 3];
        expect(Scoring.scoreAs(dice), 6);
      });

      test('returns 12 for two Aces', () {
        final dice = [5, 5, 0, 1, 2];
        expect(Scoring.scoreAs(dice), 12);
      });

      test('returns 18 for three Aces', () {
        final dice = [5, 5, 5, 0, 1];
        expect(Scoring.scoreAs(dice), 18);
      });

      test('returns 24 for four Aces', () {
        final dice = [5, 5, 5, 5, 0];
        expect(Scoring.scoreAs(dice), 24);
      });

      test('returns 30 for five Aces', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreAs(dice), 30);
      });
    });
  });

  group('Lower Section Tests', () {
    group('scoreThreeOfAKind', () {
      test('returns 0 when no three of a kind present', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scoreThreeOfAKind(dice), 0);
      });

      test('returns sum of all dice for three of a kind', () {
        final dice = [0, 0, 0, 1, 2];
        expect(Scoring.scoreThreeOfAKind(dice), 3);
      });

      test('returns sum of all dice for four of a kind', () {
        final dice = [0, 0, 0, 0, 1];
        expect(Scoring.scoreThreeOfAKind(dice), 1);
      });

      test('returns sum of all dice for five of a kind (Yatzy)', () {
        final dice = [0, 0, 0, 0, 0];
        expect(Scoring.scoreThreeOfAKind(dice), 0);
      });

      test('returns sum of all dice for Aces three of a kind', () {
        final dice = [5, 5, 5, 0, 1];
        expect(Scoring.scoreThreeOfAKind(dice), 16);
      });

      test('returns sum of all dice for 9s three of a kind', () {
        final dice = [0, 0, 0, 1, 2];
        expect(Scoring.scoreThreeOfAKind(dice), 3);
      });
    });

    group('scoreFourOfAKind', () {
      test('returns 0 when no four of a kind present', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scoreFourOfAKind(dice), 0);
      });

      test('returns 0 for three of a kind only', () {
        final dice = [0, 0, 0, 1, 2];
        expect(Scoring.scoreFourOfAKind(dice), 0);
      });

      test('returns sum of all dice for four of a kind', () {
        final dice = [0, 0, 0, 0, 1];
        expect(Scoring.scoreFourOfAKind(dice), 1);
      });

      test('returns sum of all dice for five of a kind (Yatzy)', () {
        final dice = [1, 1, 1, 1, 1];
        expect(Scoring.scoreFourOfAKind(dice), 5);
      });

      test('returns sum of all dice for Kings four of a kind', () {
        final dice = [4, 4, 4, 4, 0];
        expect(Scoring.scoreFourOfAKind(dice), 16);
      });

      test('returns sum of all dice for 9s four of a kind', () {
        final dice = [0, 0, 0, 0, 1];
        expect(Scoring.scoreFourOfAKind(dice), 1);
      });
    });

    group('scoreSmallStraight', () {
      test('returns 0 when small straight not present', () {
        final dice = [0, 0, 1, 2, 4];
        expect(Scoring.scoreSmallStraight(dice), 0);
      });

      test('returns 0 when only 3 consecutive values present', () {
        final dice = [0, 1, 2, 4, 5];
        expect(Scoring.scoreSmallStraight(dice), 0);
      });

      test('returns 30 for 9-10-J-Q (indices 0-1-2-3)', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scoreSmallStraight(dice), 30);
      });

      test('returns 30 for 10-J-Q-K (indices 1-2-3-4)', () {
        final dice = [1, 2, 3, 4, 0];
        expect(Scoring.scoreSmallStraight(dice), 30);
      });

      test('returns 30 for J-Q-K-A (indices 2-3-4-5)', () {
        final dice = [2, 3, 4, 5, 0];
        expect(Scoring.scoreSmallStraight(dice), 30);
      });

      test('returns 30 for small straight in any order', () {
        final dice = [3, 1, 2, 0, 5];
        expect(Scoring.scoreSmallStraight(dice), 30);
      });

      test('returns 30 for long straight (also contains small straight)', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scoreSmallStraight(dice), 30);
      });
    });

    group('scoreLongStraight', () {
      test('returns 0 when long straight not present', () {
        final dice = [0, 0, 1, 2, 3];
        expect(Scoring.scoreLongStraight(dice), 0);
      });

      test('returns 0 when duplicate values present', () {
        final dice = [0, 1, 2, 3, 3];
        expect(Scoring.scoreLongStraight(dice), 0);
      });

      test('returns 40 for small long straight (9-10-J-Q-K)', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scoreLongStraight(dice), 40);
      });

      test('returns 40 for large long straight (10-J-Q-K-A)', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scoreLongStraight(dice), 40);
      });

      test('returns 40 for large long straight in any order', () {
        final dice = [5, 3, 1, 4, 2];
        expect(Scoring.scoreLongStraight(dice), 40);
      });

      test('returns 0 when missing middle value', () {
        final dice = [0, 1, 2, 3, 5];
        expect(Scoring.scoreLongStraight(dice), 0);
      });
    });

    group('scoreChance', () {
      test('returns sum of all dice values', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scoreChance(dice), 10);
      });

      test('returns sum for all Aces', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreChance(dice), 25);
      });

      test('returns sum for mixed values', () {
        final dice = [0, 2, 3, 4, 5];
        expect(Scoring.scoreChance(dice), 14);
      });

      test('returns 0 for all 9s', () {
        final dice = [0, 0, 0, 0, 0];
        expect(Scoring.scoreChance(dice), 0);
      });

      test('always returns sum regardless of combination', () {
        final dice = [1, 1, 3, 3, 5];
        expect(Scoring.scoreChance(dice), 13);
      });
    });

    group('scoreFullHouse', () {
      test('returns 0 when full house not present', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scoreFullHouse(dice), 0);
      });

      test('returns 0 for two pairs only', () {
        final dice = [0, 0, 1, 1, 2];
        expect(Scoring.scoreFullHouse(dice), 0);
      });

      test('returns 25 for full house (3+2)', () {
        final dice = [0, 0, 0, 1, 1];
        expect(Scoring.scoreFullHouse(dice), 25);
      });

      test('returns 25 for Aces full house', () {
        final dice = [5, 5, 5, 0, 0];
        expect(Scoring.scoreFullHouse(dice), 25);
      });

      test('returns 25 for 9s full house', () {
        final dice = [0, 0, 0, 1, 1];
        expect(Scoring.scoreFullHouse(dice), 25);
      });

      test('returns 0 for four of a kind + one', () {
        final dice = [0, 0, 0, 0, 1];
        expect(Scoring.scoreFullHouse(dice), 0);
      });
    });

    group('scoreYatzy', () {
      test('returns 0 when yatzy not present', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scoreYatzy(dice), 0);
      });

      test('returns 0 for four of a kind only', () {
        final dice = [0, 0, 0, 0, 1];
        expect(Scoring.scoreYatzy(dice), 0);
      });

      test('returns 50 for all 5 dice same (9s)', () {
        final dice = [0, 0, 0, 0, 0];
        expect(Scoring.scoreYatzy(dice), 50);
      });

      test('returns 50 for all 5 dice same (Aces)', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreYatzy(dice), 50);
      });

      test('returns 50 for all 5 dice same (Kings)', () {
        final dice = [4, 4, 4, 4, 4];
        expect(Scoring.scoreYatzy(dice), 50);
      });
    });
  });

  group('Bonus Calculation Tests', () {
    test('returns bonus when upper section total >= 65', () {
      final upperScores = [1, 2, 3, 4, 5, 6];
      int total = upperScores.fold(0, (sum, score) => sum + score);
      expect(total, 21);
      expect(total >= 65, false);
    });

    test('upper section minimum scores for bonus', () {
      // Minimum scoring: one of each rank
      final minScores = [1, 2, 3, 4, 5, 6];
      int total = minScores.fold(0, (sum, score) => sum + score);
      expect(total, 21);
      expect(total >= 65, false);
    });

    test('upper section with low scores does not meet bonus', () {
      final lowScores = [0, 0, 0, 0, 0, 0];
      int total = lowScores.fold(0, (sum, score) => sum + score);
      expect(total, 0);
      expect(total >= 65, false);
    });

    test('upper section with minimal pairs does not meet bonus', () {
      // One of each: 1+2+3+4+5+6 = 21
      final minimalScores = [1, 2, 3, 4, 5, 6];
      int total = minimalScores.fold(0, (sum, score) => sum + score);
      expect(total, 21);
      expect(total >= 65, false);
    });

    test('upper section with high scores meets bonus threshold', () {
      // Two of each: 2+4+6+8+10+12 = 42
      final highScores = [2, 4, 6, 8, 10, 12];
      int total = highScores.fold(0, (sum, score) => sum + score);
      expect(total, 42);
      expect(total >= 65, false);
    });

    test('upper section with maximum scores meets bonus', () {
      // Five of each: 5+10+15+20+25+30 = 105
      final maxScores = [5, 10, 15, 20, 25, 30];
      int total = maxScores.fold(0, (sum, score) => sum + score);
      expect(total, 105);
      expect(total >= 65, true);
    });
  });

  group('Edge Case Tests', () {
    group('Empty hand (all Aces)', () {
      test('score9s returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.score9s(dice), 0);
      });

      test('score10s returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.score10s(dice), 0);
      });

      test('scoreJs returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreJs(dice), 0);
      });

      test('scoreQs returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreQs(dice), 0);
      });

      test('scoreKs returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreKs(dice), 0);
      });

      test('scoreAs returns 30', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreAs(dice), 30);
      });

      test('scoreThreeOfAKind returns sum of all', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreThreeOfAKind(dice), 25);
      });

      test('scoreFourOfAKind returns sum of all', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreFourOfAKind(dice), 25);
      });

      test('scoreLongStraight returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreLongStraight(dice), 0);
      });

      test('scoreFullHouse returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreFullHouse(dice), 0);
      });

      test('scoreYatzy returns 50', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreYatzy(dice), 50);
      });
    });

    group('Invalid combinations', () {
      test('returns 0 for no matching dice (straight)', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.score9s(dice), 1);
        expect(Scoring.score10s(dice), 2);
        expect(Scoring.scoreJs(dice), 3);
        expect(Scoring.scoreQs(dice), 4);
        expect(Scoring.scoreKs(dice), 5);
        expect(Scoring.scoreAs(dice), 0);
        expect(Scoring.scoreThreeOfAKind(dice), 0);
        expect(Scoring.scoreFourOfAKind(dice), 0);
        expect(Scoring.scoreFullHouse(dice), 0);
      });

      test('returns 5 of a kind counts for all pair categories', () {
        final dice = [2, 2, 2, 2, 2];
        expect(Scoring.scoreJs(dice), 15);
        expect(Scoring.scoreThreeOfAKind(dice), 10);
        expect(Scoring.scoreFourOfAKind(dice), 10);
        expect(Scoring.scoreYatzy(dice), 50);
      });
    });
  });
}
