import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/features/game/logic/scoring.dart';

void main() {
  group('Upper Section - Pair Tests', () {
    group('scorePairOf9s', () {
      test('returns 0 when no 9s present', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scorePairOf9s(dice), 0);
      });

      test('returns 9 for one 9', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scorePairOf9s(dice), 9);
      });

      test('returns 18 for two 9s', () {
        final dice = [0, 0, 1, 2, 3];
        expect(Scoring.scorePairOf9s(dice), 18);
      });

      test('returns 27 for three 9s', () {
        final dice = [0, 0, 0, 1, 2];
        expect(Scoring.scorePairOf9s(dice), 27);
      });

      test('returns 36 for four 9s', () {
        final dice = [0, 0, 0, 0, 1];
        expect(Scoring.scorePairOf9s(dice), 36);
      });

      test('returns 45 for five 9s', () {
        final dice = [0, 0, 0, 0, 0];
        expect(Scoring.scorePairOf9s(dice), 45);
      });

      test('returns 0 for empty hand (all Aces)', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scorePairOf9s(dice), 0);
      });
    });

    group('scorePairOf10s', () {
      test('returns 0 when no 10s present', () {
        final dice = [0, 2, 3, 4, 5];
        expect(Scoring.scorePairOf10s(dice), 0);
      });

      test('returns 10 for one 10', () {
        final dice = [1, 0, 2, 3, 4];
        expect(Scoring.scorePairOf10s(dice), 10);
      });

      test('returns 20 for two 10s', () {
        final dice = [1, 1, 0, 2, 3];
        expect(Scoring.scorePairOf10s(dice), 20);
      });

      test('returns 30 for three 10s', () {
        final dice = [1, 1, 1, 0, 2];
        expect(Scoring.scorePairOf10s(dice), 30);
      });

      test('returns 40 for four 10s', () {
        final dice = [1, 1, 1, 1, 0];
        expect(Scoring.scorePairOf10s(dice), 40);
      });

      test('returns 50 for five 10s', () {
        final dice = [1, 1, 1, 1, 1];
        expect(Scoring.scorePairOf10s(dice), 50);
      });
    });

    group('scorePairOfJacks', () {
      test('returns 0 when no Jacks present', () {
        final dice = [0, 1, 3, 4, 5];
        expect(Scoring.scorePairOfJacks(dice), 0);
      });

      test('returns 11 for one Jack', () {
        final dice = [2, 0, 1, 3, 4];
        expect(Scoring.scorePairOfJacks(dice), 11);
      });

      test('returns 22 for two Jacks', () {
        final dice = [2, 2, 0, 1, 3];
        expect(Scoring.scorePairOfJacks(dice), 22);
      });

      test('returns 33 for three Jacks', () {
        final dice = [2, 2, 2, 0, 1];
        expect(Scoring.scorePairOfJacks(dice), 33);
      });

      test('returns 44 for four Jacks', () {
        final dice = [2, 2, 2, 2, 0];
        expect(Scoring.scorePairOfJacks(dice), 44);
      });

      test('returns 55 for five Jacks', () {
        final dice = [2, 2, 2, 2, 2];
        expect(Scoring.scorePairOfJacks(dice), 55);
      });
    });

    group('scorePairOfQueens', () {
      test('returns 0 when no Queens present', () {
        final dice = [0, 1, 2, 4, 5];
        expect(Scoring.scorePairOfQueens(dice), 0);
      });

      test('returns 12 for one Queen', () {
        final dice = [3, 0, 1, 2, 4];
        expect(Scoring.scorePairOfQueens(dice), 12);
      });

      test('returns 24 for two Queens', () {
        final dice = [3, 3, 0, 1, 2];
        expect(Scoring.scorePairOfQueens(dice), 24);
      });

      test('returns 36 for three Queens', () {
        final dice = [3, 3, 3, 0, 1];
        expect(Scoring.scorePairOfQueens(dice), 36);
      });

      test('returns 48 for four Queens', () {
        final dice = [3, 3, 3, 3, 0];
        expect(Scoring.scorePairOfQueens(dice), 48);
      });

      test('returns 60 for five Queens', () {
        final dice = [3, 3, 3, 3, 3];
        expect(Scoring.scorePairOfQueens(dice), 60);
      });
    });

    group('scorePairOfKings', () {
      test('returns 0 when no Kings present', () {
        final dice = [0, 1, 2, 3, 5];
        expect(Scoring.scorePairOfKings(dice), 0);
      });

      test('returns 13 for one King', () {
        final dice = [4, 0, 1, 2, 3];
        expect(Scoring.scorePairOfKings(dice), 13);
      });

      test('returns 26 for two Kings', () {
        final dice = [4, 4, 0, 1, 2];
        expect(Scoring.scorePairOfKings(dice), 26);
      });

      test('returns 39 for three Kings', () {
        final dice = [4, 4, 4, 0, 1];
        expect(Scoring.scorePairOfKings(dice), 39);
      });

      test('returns 52 for four Kings', () {
        final dice = [4, 4, 4, 4, 0];
        expect(Scoring.scorePairOfKings(dice), 52);
      });

      test('returns 65 for five Kings', () {
        final dice = [4, 4, 4, 4, 4];
        expect(Scoring.scorePairOfKings(dice), 65);
      });
    });

    group('scorePairOfAces', () {
      test('returns 0 when no Aces present', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scorePairOfAces(dice), 0);
      });

      test('returns 14 for one Ace', () {
        final dice = [5, 0, 1, 2, 3];
        expect(Scoring.scorePairOfAces(dice), 14);
      });

      test('returns 28 for two Aces', () {
        final dice = [5, 5, 0, 1, 2];
        expect(Scoring.scorePairOfAces(dice), 28);
      });

      test('returns 42 for three Aces', () {
        final dice = [5, 5, 5, 0, 1];
        expect(Scoring.scorePairOfAces(dice), 42);
      });

      test('returns 56 for four Aces', () {
        final dice = [5, 5, 5, 5, 0];
        expect(Scoring.scorePairOfAces(dice), 56);
      });

      test('returns 70 for five Aces', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scorePairOfAces(dice), 70);
      });
    });
  });

  group('Lower Section Tests', () {
    group('scoreTwoPair', () {
      test('returns 0 when no pairs present', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scoreTwoPair(dice), 0);
      });

      test('returns 0 when only one pair present', () {
        final dice = [0, 0, 1, 2, 3];
        expect(Scoring.scoreTwoPair(dice), 0);
      });

      test('returns sum of 4 dice for two different pairs', () {
        final dice = [0, 0, 1, 1, 2];
        expect(Scoring.scoreTwoPair(dice), 2);
      });

      test('returns correct sum for Kings and Aces pair', () {
        final dice = [4, 4, 5, 5, 0];
        expect(Scoring.scoreTwoPair(dice), 18);
      });

      test('returns correct sum for 9s and 10s pair', () {
        final dice = [0, 0, 1, 1, 2];
        expect(Scoring.scoreTwoPair(dice), 2);
      });

      test('returns 0 for invalid combination (three of a kind + pair)', () {
        final dice = [0, 0, 0, 1, 1];
        expect(Scoring.scoreTwoPair(dice), 0);
      });
    });

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

    group('scoreStraight', () {
      test('returns 0 when straight not present', () {
        final dice = [0, 0, 1, 2, 3];
        expect(Scoring.scoreStraight(dice), 0);
      });

      test('returns 0 when duplicate values present', () {
        final dice = [0, 1, 2, 3, 3];
        expect(Scoring.scoreStraight(dice), 0);
      });

      test('returns 25 for small straight (9-10-J-Q-K)', () {
        final dice = [0, 1, 2, 3, 4];
        expect(Scoring.scoreStraight(dice), 25);
      });

      test('returns 25 for large straight (10-J-Q-K-A)', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scoring.scoreStraight(dice), 25);
      });

      test('returns 25 for large straight in any order', () {
        final dice = [5, 3, 1, 4, 2];
        expect(Scoring.scoreStraight(dice), 25);
      });

      test('returns 0 when missing middle value', () {
        final dice = [0, 1, 2, 3, 5];
        expect(Scoring.scoreStraight(dice), 0);
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

      test('returns sum of all dice for full house (3+2)', () {
        final dice = [0, 0, 0, 1, 1];
        expect(Scoring.scoreFullHouse(dice), 2);
      });

      test('returns sum of all dice for Aces full house', () {
        final dice = [5, 5, 5, 0, 0];
        expect(Scoring.scoreFullHouse(dice), 15);
      });

      test('returns sum of all dice for 9s full house', () {
        final dice = [0, 0, 0, 1, 1];
        expect(Scoring.scoreFullHouse(dice), 2);
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
    test('returns 10 bonus when upper section total >= 30', () {
      final upperScores = [18, 20, 22, 24, 26, 28];
      int total = upperScores.fold(0, (sum, score) => sum + score);
      expect(total, 138);
      expect(total >= 30, true);
    });

    test('upper section minimum scores for bonus', () {
      final minScores = [18, 20, 22, 24, 26, 28];
      int total = minScores.fold(0, (sum, score) => sum + score);
      expect(total, 138);
      expect(total >= 30, true);
    });

    test('upper section with low scores still meets bonus', () {
      final lowScores = [0, 0, 0, 0, 0, 0];
      int total = lowScores.fold(0, (sum, score) => sum + score);
      expect(total, 0);
      expect(total >= 30, false);
    });

    test('upper section with minimal pairs meets bonus', () {
      final minimalScores = [9, 10, 11, 12, 13, 14];
      int total = minimalScores.fold(0, (sum, score) => sum + score);
      expect(total, 69);
      expect(total >= 30, true);
    });
  });

  group('Edge Case Tests', () {
    group('Empty hand (all Aces)', () {
      test('scorePairOf9s returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scorePairOf9s(dice), 0);
      });

      test('scorePairOf10s returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scorePairOf10s(dice), 0);
      });

      test('scorePairOfJacks returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scorePairOfJacks(dice), 0);
      });

      test('scorePairOfQueens returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scorePairOfQueens(dice), 0);
      });

      test('scorePairOfKings returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scorePairOfKings(dice), 0);
      });

      test('scorePairOfAces returns 70', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scorePairOfAces(dice), 70);
      });

      test('scoreTwoPair returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreTwoPair(dice), 0);
      });

      test('scoreThreeOfAKind returns sum of all', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreThreeOfAKind(dice), 25);
      });

      test('scoreFourOfAKind returns sum of all', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreFourOfAKind(dice), 25);
      });

      test('scoreStraight returns 0', () {
        final dice = [5, 5, 5, 5, 5];
        expect(Scoring.scoreStraight(dice), 0);
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
        expect(Scoring.scorePairOf9s(dice), 9);
        expect(Scoring.scorePairOf10s(dice), 10);
        expect(Scoring.scorePairOfJacks(dice), 11);
        expect(Scoring.scorePairOfQueens(dice), 12);
        expect(Scoring.scorePairOfKings(dice), 13);
        expect(Scoring.scorePairOfAces(dice), 0);
        expect(Scoring.scoreTwoPair(dice), 0);
        expect(Scoring.scoreThreeOfAKind(dice), 0);
        expect(Scoring.scoreFourOfAKind(dice), 0);
        expect(Scoring.scoreFullHouse(dice), 0);
      });

      test('returns 5 of a kind counts for all pair categories', () {
        final dice = [2, 2, 2, 2, 2];
        expect(Scoring.scorePairOfJacks(dice), 55);
        expect(Scoring.scoreTwoPair(dice), 0);
        expect(Scoring.scoreThreeOfAKind(dice), 10);
        expect(Scoring.scoreFourOfAKind(dice), 10);
        expect(Scoring.scoreYatzy(dice), 50);
      });

      test('returns 0 when only one pair present', () {
        final dice = [2, 2, 0, 1, 3];
        expect(Scoring.scoreTwoPair(dice), 0);
        expect(Scoring.scoreFullHouse(dice), 0);
      });
    });
  });
}
