import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/scoring/scorer.dart';

void main() {
  group('Scorer', () {
    group('Upper Section', () {
      group('scoreAces', () {
        test('returns 0 when no aces present', () {
          final dice = [2, 3, 4, 5, 6];
          expect(Scorer.scoreAces(dice), 0);
        });

        test('returns sum of all aces', () {
          final dice = [1, 1, 2, 3, 4];
          expect(Scorer.scoreAces(dice), 2);
        });

        test('returns sum when all dice are aces', () {
          final dice = [1, 1, 1, 1, 1];
          expect(Scorer.scoreAces(dice), 5);
        });

        test('returns correct sum with single ace', () {
          final dice = [1, 2, 3, 4, 5];
          expect(Scorer.scoreAces(dice), 1);
        });
      });

      group('scoreTwos', () {
        test('returns 0 when no twos present', () {
          final dice = [1, 3, 4, 5, 6];
          expect(Scorer.scoreTwos(dice), 0);
        });

        test('returns sum of all twos', () {
          final dice = [1, 2, 2, 2, 4];
          expect(Scorer.scoreTwos(dice), 6);
        });

        test('returns sum when all dice are twos', () {
          final dice = [2, 2, 2, 2, 2];
          expect(Scorer.scoreTwos(dice), 10);
        });
      });

      group('scoreThrees', () {
        test('returns 0 when no threes present', () {
          final dice = [1, 2, 4, 5, 6];
          expect(Scorer.scoreThrees(dice), 0);
        });

        test('returns sum of all threes', () {
          final dice = [1, 3, 3, 4, 6];
          expect(Scorer.scoreThrees(dice), 6);
        });

        test('returns sum when all dice are threes', () {
          final dice = [3, 3, 3, 3, 3];
          expect(Scorer.scoreThrees(dice), 15);
        });
      });

      group('scoreFours', () {
        test('returns 0 when no fours present', () {
          final dice = [1, 2, 3, 5, 6];
          expect(Scorer.scoreFours(dice), 0);
        });

        test('returns sum of all fours', () {
          final dice = [1, 4, 4, 5, 6];
          expect(Scorer.scoreFours(dice), 8);
        });

        test('returns sum when all dice are fours', () {
          final dice = [4, 4, 4, 4, 4];
          expect(Scorer.scoreFours(dice), 20);
        });
      });

      group('scoreFives', () {
        test('returns 0 when no fives present', () {
          final dice = [1, 2, 3, 4, 6];
          expect(Scorer.scoreFives(dice), 0);
        });

        test('returns sum of all fives', () {
          final dice = [1, 5, 5, 5, 6];
          expect(Scorer.scoreFives(dice), 15);
        });

        test('returns sum when all dice are fives', () {
          final dice = [5, 5, 5, 5, 5];
          expect(Scorer.scoreFives(dice), 25);
        });
      });

      group('scoreSixes', () {
        test('returns 0 when no sixes present', () {
          final dice = [1, 2, 3, 4, 5];
          expect(Scorer.scoreSixes(dice), 0);
        });

        test('returns sum of all sixes', () {
          final dice = [1, 2, 6, 6, 6];
          expect(Scorer.scoreSixes(dice), 18);
        });

        test('returns sum when all dice are sixes', () {
          final dice = [6, 6, 6, 6, 6];
          expect(Scorer.scoreSixes(dice), 30);
        });
      });
    });

    group('Lower Section', () {
      group('scoreThreeOfKind', () {
        test('returns 0 when no three of a kind', () {
          final dice = [1, 2, 3, 4, 5];
          expect(Scorer.scoreThreeOfKind(dice), 0);
        });

        test('returns sum of all dice when three of a kind present', () {
          final dice = [3, 3, 3, 4, 5];
          expect(Scorer.scoreThreeOfKind(dice), 18);
        });

        test('returns sum when four of a kind present', () {
          final dice = [2, 2, 2, 2, 5];
          expect(Scorer.scoreThreeOfKind(dice), 13);
        });

        test('returns sum when five of a kind present', () {
          final dice = [4, 4, 4, 4, 4];
          expect(Scorer.scoreThreeOfKind(dice), 20);
        });

        test('returns sum with mixed values', () {
          final dice = [1, 1, 1, 6, 6];
          expect(Scorer.scoreThreeOfKind(dice), 15);
        });
      });

      group('scoreFourOfKind', () {
        test('returns 0 when no four of a kind', () {
          final dice = [1, 2, 3, 4, 5];
          expect(Scorer.scoreFourOfKind(dice), 0);
        });

        test('returns 0 when three of a kind but not four', () {
          final dice = [3, 3, 3, 4, 5];
          expect(Scorer.scoreFourOfKind(dice), 0);
        });

        test('returns sum of all dice when four of a kind present', () {
          final dice = [2, 2, 2, 2, 5];
          expect(Scorer.scoreFourOfKind(dice), 13);
        });

        test('returns sum when five of a kind present', () {
          final dice = [5, 5, 5, 5, 5];
          expect(Scorer.scoreFourOfKind(dice), 25);
        });

        test('returns sum with low values', () {
          final dice = [1, 1, 1, 1, 6];
          expect(Scorer.scoreFourOfKind(dice), 10);
        });
      });

      group('scoreFullHouse', () {
        test('returns 0 when no full house', () {
          final dice = [1, 2, 3, 4, 5];
          expect(Scorer.scoreFullHouse(dice), 0);
        });

        test('returns 25 for valid full house (3+2)', () {
          final dice = [3, 3, 3, 5, 5];
          expect(Scorer.scoreFullHouse(dice), 25);
        });

        test('returns 25 for valid full house with different values', () {
          final dice = [1, 1, 1, 6, 6];
          expect(Scorer.scoreFullHouse(dice), 25);
        });

        test('returns 0 for four of a kind + one (NOT full house)', () {
          final dice = [2, 2, 2, 2, 5];
          expect(Scorer.scoreFullHouse(dice), 0);
        });

        test('returns 0 for five of a kind (NOT full house)', () {
          final dice = [4, 4, 4, 4, 4];
          expect(Scorer.scoreFullHouse(dice), 0);
        });

        test('returns 0 for three of a kind + two different', () {
          final dice = [3, 3, 3, 4, 5];
          expect(Scorer.scoreFullHouse(dice), 0);
        });

        test('returns 0 for two pairs + one', () {
          final dice = [2, 2, 4, 4, 6];
          expect(Scorer.scoreFullHouse(dice), 0);
        });

        test('returns 25 for full house with 1s and 6s', () {
          final dice = [1, 1, 1, 6, 6];
          expect(Scorer.scoreFullHouse(dice), 25);
        });
      });

      group('scoreSmallStraight', () {
        test('returns 0 when no small straight', () {
          final dice = [1, 1, 3, 5, 6];
          expect(Scorer.scoreSmallStraight(dice), 0);
        });

        test('returns 30 for 1-2-3-4 straight', () {
          final dice = [1, 2, 3, 4, 6];
          expect(Scorer.scoreSmallStraight(dice), 30);
        });

        test('returns 30 for 2-3-4-5 straight', () {
          final dice = [1, 2, 3, 4, 5];
          expect(Scorer.scoreSmallStraight(dice), 30);
        });

        test('returns 30 for 3-4-5-6 straight', () {
          final dice = [1, 3, 4, 5, 6];
          expect(Scorer.scoreSmallStraight(dice), 30);
        });

        test('returns 30 for large straight (can score as small)', () {
          final dice = [2, 3, 4, 5, 6];
          expect(Scorer.scoreSmallStraight(dice), 30);
        });

        test('returns 30 with duplicate values in straight', () {
          final dice = [1, 2, 2, 3, 4];
          expect(Scorer.scoreSmallStraight(dice), 30);
        });

        test('returns 30 with duplicates at end', () {
          final dice = [2, 3, 4, 5, 5];
          expect(Scorer.scoreSmallStraight(dice), 30);
        });

        test('returns 0 for near-miss straight', () {
          final dice = [1, 2, 4, 5, 6];
          expect(Scorer.scoreSmallStraight(dice), 0);
        });
      });

      group('scoreLargeStraight', () {
        test('returns 0 when no large straight', () {
          final dice = [1, 2, 3, 4, 4];
          expect(Scorer.scoreLargeStraight(dice), 0);
        });

        test('returns 40 for 1-2-3-4-5 straight', () {
          final dice = [1, 2, 3, 4, 5];
          expect(Scorer.scoreLargeStraight(dice), 40);
        });

        test('returns 40 for 2-3-4-5-6 straight', () {
          final dice = [2, 3, 4, 5, 6];
          expect(Scorer.scoreLargeStraight(dice), 40);
        });

        test('returns 0 for small straight only', () {
          final dice = [1, 2, 3, 4, 6];
          expect(Scorer.scoreLargeStraight(dice), 0);
        });

        test('returns 0 for near-miss large straight', () {
          final dice = [1, 2, 3, 5, 6];
          expect(Scorer.scoreLargeStraight(dice), 0);
        });

        test('returns 0 when dice has duplicates', () {
          final dice = [1, 2, 3, 4, 4];
          expect(Scorer.scoreLargeStraight(dice), 0);
        });
      });

      group('scoreYatzy', () {
        test('returns 0 when no yatzy', () {
          final dice = [1, 2, 3, 4, 5];
          expect(Scorer.scoreYatzy(dice), 0);
        });

        test('returns 50 for first yatzy', () {
          final dice = [5, 5, 5, 5, 5];
          expect(Scorer.scoreYatzy(dice, yatzyCount: 0), 50);
        });

        test('returns 100 for second yatzy (with bonus)', () {
          final dice = [3, 3, 3, 3, 3];
          expect(Scorer.scoreYatzy(dice, yatzyCount: 1), 100);
        });

        test('returns 150 for third yatzy (with bonus)', () {
          final dice = [6, 6, 6, 6, 6];
          expect(Scorer.scoreYatzy(dice, yatzyCount: 2), 150);
        });

        test('returns 50 for yatzy with 1s', () {
          final dice = [1, 1, 1, 1, 1];
          expect(Scorer.scoreYatzy(dice), 50);
        });

        test('returns 50 for yatzy with 6s', () {
          final dice = [6, 6, 6, 6, 6];
          expect(Scorer.scoreYatzy(dice), 50);
        });

        test('returns 0 for four of a kind (not yatzy)', () {
          final dice = [4, 4, 4, 4, 2];
          expect(Scorer.scoreYatzy(dice), 0);
        });
      });

      group('scoreChance', () {
        test('returns sum of all dice', () {
          final dice = [1, 2, 3, 4, 5];
          expect(Scorer.scoreChance(dice), 15);
        });

        test('returns sum with duplicate values', () {
          final dice = [3, 3, 3, 3, 3];
          expect(Scorer.scoreChance(dice), 15);
        });

        test('returns sum with mixed values', () {
          final dice = [1, 6, 2, 5, 3];
          expect(Scorer.scoreChance(dice), 17);
        });

        test('returns 0 for empty list', () {
          final dice = <int>[];
          expect(Scorer.scoreChance(dice), 0);
        });

        test('returns correct sum for all 1s', () {
          final dice = [1, 1, 1, 1, 1];
          expect(Scorer.scoreChance(dice), 5);
        });

        test('returns correct sum for all 6s', () {
          final dice = [6, 6, 6, 6, 6];
          expect(Scorer.scoreChance(dice), 30);
        });
      });
    });

    group('Edge Cases', () {
      test('handles empty dice list for upper section', () {
        final dice = <int>[];
        expect(Scorer.scoreAces(dice), 0);
        expect(Scorer.scoreTwos(dice), 0);
        expect(Scorer.scoreChance(dice), 0);
      });

      test('handles empty dice list for lower section', () {
        final dice = <int>[];
        expect(Scorer.scoreThreeOfKind(dice), 0);
        expect(Scorer.scoreFourOfKind(dice), 0);
        expect(Scorer.scoreFullHouse(dice), 0);
        expect(Scorer.scoreSmallStraight(dice), 0);
        expect(Scorer.scoreLargeStraight(dice), 0);
        expect(Scorer.scoreYatzy(dice), 0);
      });

      test('handles single die', () {
        final dice = [3];
        expect(Scorer.scoreAces(dice), 0);
        expect(Scorer.scoreThrees(dice), 3);
        expect(Scorer.scoreChance(dice), 3);
        expect(Scorer.scoreThreeOfKind(dice), 0);
        expect(Scorer.scoreFullHouse(dice), 0);
      });

      test('handles all same values (yatzy scenario)', () {
        final dice = [4, 4, 4, 4, 4];
        expect(Scorer.scoreFours(dice), 20);
        expect(Scorer.scoreThreeOfKind(dice), 20);
        expect(Scorer.scoreFourOfKind(dice), 20);
        expect(Scorer.scoreFullHouse(dice), 0);
        expect(Scorer.scoreSmallStraight(dice), 0);
        expect(Scorer.scoreLargeStraight(dice), 0);
        expect(Scorer.scoreYatzy(dice), 50);
        expect(Scorer.scoreChance(dice), 20);
      });

      test('handles maximum score scenarios', () {
        final dice = [6, 6, 6, 6, 6];
        expect(Scorer.scoreSixes(dice), 30);
        expect(Scorer.scoreThreeOfKind(dice), 30);
        expect(Scorer.scoreFourOfKind(dice), 30);
        expect(Scorer.scoreYatzy(dice), 50);
        expect(Scorer.scoreChance(dice), 30);
      });

      test('handles minimum score scenarios', () {
        final dice = [1, 2, 3, 4, 5];
        expect(Scorer.scoreAces(dice), 1);
        expect(Scorer.scoreSmallStraight(dice), 30);
        expect(Scorer.scoreLargeStraight(dice), 40);
        expect(Scorer.scoreChance(dice), 15);
      });

      test('distinguishes full house from four of a kind + one', () {
        final fullHouse = [2, 2, 2, 5, 5];
        final fourPlusOne = [2, 2, 2, 2, 5];

        expect(Scorer.scoreFullHouse(fullHouse), 25);
        expect(Scorer.scoreFullHouse(fourPlusOne), 0);

        expect(Scorer.scoreThreeOfKind(fullHouse), 16);
        expect(Scorer.scoreThreeOfKind(fourPlusOne), 13);

        expect(Scorer.scoreFourOfKind(fullHouse), 0);
        expect(Scorer.scoreFourOfKind(fourPlusOne), 13);
      });

      test('distinguishes small straight from large straight', () {
        final smallOnly = [1, 2, 3, 4, 6];
        final large = [1, 2, 3, 4, 5];

        expect(Scorer.scoreSmallStraight(smallOnly), 30);
        expect(Scorer.scoreLargeStraight(smallOnly), 0);

        expect(Scorer.scoreSmallStraight(large), 30);
        expect(Scorer.scoreLargeStraight(large), 40);
      });
    });
  });
}
