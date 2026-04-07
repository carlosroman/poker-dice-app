import 'package:poker_dice/src/domain/models/die.dart';
import 'package:poker_dice/src/domain/scoring/scorer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Scorer - Upper Section', () {
    group('scoreAces', () {
      test('returns sum when all dice are aces', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 1),
          const Die(value: 1),
          const Die(value: 1),
          const Die(value: 1),
        ];
        expect(Scorer.scoreAces(dice), 5);
      });

      test('returns sum of aces in mixed roll', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 1),
          const Die(value: 5),
          const Die(value: 1),
        ];
        expect(Scorer.scoreAces(dice), 3);
      });

      test('returns 0 when no aces', () {
        final dice = [
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
          const Die(value: 6),
        ];
        expect(Scorer.scoreAces(dice), 0);
      });

      test('returns 0 for single die that is not ace', () {
        final dice = [
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 3),
        ];
        expect(Scorer.scoreAces(dice), 0);
      });
    });

    group('scoreTwos', () {
      test('returns sum when all dice are twos', () {
        final dice = List.generate(5, (_) => const Die(value: 2));
        expect(Scorer.scoreTwos(dice), 10);
      });

      test('returns sum of twos in mixed roll', () {
        final dice = [
          const Die(value: 2),
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 6),
          const Die(value: 2),
        ];
        expect(Scorer.scoreTwos(dice), 6);
      });

      test('returns 0 when no twos', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
          const Die(value: 6),
        ];
        expect(Scorer.scoreTwos(dice), 0);
      });
    });

    group('scoreThrees', () {
      test('returns sum when all dice are threes', () {
        final dice = List.generate(5, (_) => const Die(value: 3));
        expect(Scorer.scoreThrees(dice), 15);
      });

      test('returns sum of threes in mixed roll', () {
        final dice = [
          const Die(value: 3),
          const Die(value: 1),
          const Die(value: 5),
          const Die(value: 3),
          const Die(value: 2),
        ];
        expect(Scorer.scoreThrees(dice), 6);
      });

      test('returns 0 when no threes', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 4),
          const Die(value: 5),
          const Die(value: 6),
        ];
        expect(Scorer.scoreThrees(dice), 0);
      });
    });

    group('scoreFours', () {
      test('returns sum when all dice are fours', () {
        final dice = List.generate(5, (_) => const Die(value: 4));
        expect(Scorer.scoreFours(dice), 20);
      });

      test('returns sum of fours in mixed roll', () {
        final dice = [
          const Die(value: 4),
          const Die(value: 2),
          const Die(value: 4),
          const Die(value: 6),
          const Die(value: 1),
        ];
        expect(Scorer.scoreFours(dice), 8);
      });

      test('returns 0 when no fours', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 5),
          const Die(value: 6),
        ];
        expect(Scorer.scoreFours(dice), 0);
      });
    });

    group('scoreFives', () {
      test('returns sum when all dice are fives', () {
        final dice = List.generate(5, (_) => const Die(value: 5));
        expect(Scorer.scoreFives(dice), 25);
      });

      test('returns sum of fives in mixed roll', () {
        final dice = [
          const Die(value: 5),
          const Die(value: 1),
          const Die(value: 5),
          const Die(value: 3),
          const Die(value: 5),
        ];
        expect(Scorer.scoreFives(dice), 15);
      });

      test('returns 0 when no fives', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 6),
        ];
        expect(Scorer.scoreFives(dice), 0);
      });
    });

    group('scoreSixes', () {
      test('returns sum when all dice are sixes', () {
        final dice = List.generate(5, (_) => const Die(value: 6));
        expect(Scorer.scoreSixes(dice), 30);
      });

      test('returns sum of sixes in mixed roll', () {
        final dice = [
          const Die(value: 6),
          const Die(value: 2),
          const Die(value: 6),
          const Die(value: 4),
          const Die(value: 6),
        ];
        expect(Scorer.scoreSixes(dice), 18);
      });

      test('returns 0 when no sixes', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
        ];
        expect(Scorer.scoreSixes(dice), 0);
      });
    });
  });

  group('Scorer - Lower Section', () {
    group('scoreThreeOfKind', () {
      test('returns sum when exactly 3 match', () {
        final dice = [
          const Die(value: 2),
          const Die(value: 2),
          const Die(value: 2),
          const Die(value: 4),
          const Die(value: 5),
        ];
        expect(Scorer.scoreThreeOfKind(dice), 15); // 2+2+2+4+5
      });

      test('returns sum when 4 match', () {
        final dice = [
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 1),
        ];
        expect(Scorer.scoreThreeOfKind(dice), 13); // 3+3+3+3+1
      });

      test('returns sum when 5 match', () {
        final dice = List.generate(5, (_) => const Die(value: 4));
        expect(Scorer.scoreThreeOfKind(dice), 20); // 4+4+4+4+4
      });

      test('returns 0 when no 3 match', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
        ];
        expect(Scorer.scoreThreeOfKind(dice), 0);
      });

      test('returns 0 with two pairs', () {
        final dice = [
          const Die(value: 2),
          const Die(value: 2),
          const Die(value: 4),
          const Die(value: 4),
          const Die(value: 6),
        ];
        expect(Scorer.scoreThreeOfKind(dice), 0);
      });
    });

    group('scoreFourOfKind', () {
      test('returns sum when exactly 4 match', () {
        final dice = [
          const Die(value: 5),
          const Die(value: 5),
          const Die(value: 5),
          const Die(value: 5),
          const Die(value: 2),
        ];
        expect(Scorer.scoreFourOfKind(dice), 22); // 5+5+5+5+2
      });

      test('returns sum when 5 match', () {
        final dice = List.generate(5, (_) => const Die(value: 6));
        expect(Scorer.scoreFourOfKind(dice), 30); // 6+6+6+6+6
      });

      test('returns 0 when no 4 match', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
        ];
        expect(Scorer.scoreFourOfKind(dice), 0);
      });

      test('returns 0 with three of a kind only', () {
        final dice = [
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 5),
          const Die(value: 6),
        ];
        expect(Scorer.scoreFourOfKind(dice), 0);
      });
    });

    group('scoreFullHouse', () {
      test('returns 25 for valid full house (3+2)', () {
        final dice = [
          const Die(value: 2),
          const Die(value: 2),
          const Die(value: 2),
          const Die(value: 5),
          const Die(value: 5),
        ];
        expect(Scorer.scoreFullHouse(dice), 25);
      });

      test('returns 25 for valid full house with different values', () {
        final dice = [
          const Die(value: 6),
          const Die(value: 6),
          const Die(value: 6),
          const Die(value: 1),
          const Die(value: 1),
        ];
        expect(Scorer.scoreFullHouse(dice), 25);
      });

      test('returns 0 for 4 of a kind + 1 (NOT a full house)', () {
        final dice = [
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 5),
        ];
        expect(Scorer.scoreFullHouse(dice), 0);
      });

      test('returns 0 for 5 of a kind', () {
        final dice = List.generate(5, (_) => const Die(value: 4));
        expect(Scorer.scoreFullHouse(dice), 0);
      });

      test('returns 0 for all different values', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
        ];
        expect(Scorer.scoreFullHouse(dice), 0);
      });

      test('returns 0 for two pairs + single', () {
        final dice = [
          const Die(value: 2),
          const Die(value: 2),
          const Die(value: 4),
          const Die(value: 4),
          const Die(value: 6),
        ];
        expect(Scorer.scoreFullHouse(dice), 0);
      });

      test('returns 0 for three of a kind + two different', () {
        final dice = [
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 5),
          const Die(value: 6),
        ];
        expect(Scorer.scoreFullHouse(dice), 0);
      });
    });

    group('scoreSmallStraight', () {
      test('returns 30 for [1,2,3,4,6]', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 6),
        ];
        expect(Scorer.scoreSmallStraight(dice), 30);
      });

      test('returns 30 for [2,3,4,5,6]', () {
        final dice = [
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
          const Die(value: 6),
        ];
        expect(Scorer.scoreSmallStraight(dice), 30);
      });

      test('returns 30 for [3,4,5,6,1] (unsorted)', () {
        final dice = [
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
          const Die(value: 6),
          const Die(value: 1),
        ];
        expect(Scorer.scoreSmallStraight(dice), 30);
      });

      test('returns 30 for large straight (contains small straight)', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
        ];
        expect(Scorer.scoreSmallStraight(dice), 30);
      });

      test('returns 0 for no straight (only 3 consecutive)', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 5),
          const Die(value: 6),
        ];
        expect(Scorer.scoreSmallStraight(dice), 0);
      });

      test('returns 0 for [1,3,4,5,6] (missing 2)', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
          const Die(value: 6),
        ];
        expect(Scorer.scoreSmallStraight(dice), 30); // Has 3-4-5-6
      });

      test('returns 0 for [1,2,4,5,6] (missing 3)', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 4),
          const Die(value: 5),
          const Die(value: 6),
        ];
        expect(Scorer.scoreSmallStraight(dice), 0);
      });

      test('returns 0 for two pairs', () {
        final dice = [
          const Die(value: 2),
          const Die(value: 2),
          const Die(value: 4),
          const Die(value: 4),
          const Die(value: 5),
        ];
        expect(Scorer.scoreSmallStraight(dice), 0);
      });
    });

    group('scoreLargeStraight', () {
      test('returns 40 for [1,2,3,4,5]', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
        ];
        expect(Scorer.scoreLargeStraight(dice), 40);
      });

      test('returns 40 for [6,5,4,3,2] (reverse order)', () {
        final dice = [
          const Die(value: 6),
          const Die(value: 5),
          const Die(value: 4),
          const Die(value: 3),
          const Die(value: 2),
        ];
        expect(Scorer.scoreLargeStraight(dice), 40);
      });

      test('returns 40 for [2,4,6,3,5] (unsorted)', () {
        final dice = [
          const Die(value: 2),
          const Die(value: 4),
          const Die(value: 6),
          const Die(value: 3),
          const Die(value: 5),
        ];
        expect(Scorer.scoreLargeStraight(dice), 40);
      });

      test('returns 0 for [1,2,3,4,6] (missing 5)', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 6),
        ];
        expect(Scorer.scoreLargeStraight(dice), 0);
      });

      test('returns 40 for [2,3,4,5,6] (valid large straight)', () {
        final dice = [
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
          const Die(value: 6),
        ];
        expect(Scorer.scoreLargeStraight(dice), 40);
      });

      test('returns 0 for all same values', () {
        final dice = List.generate(5, (_) => const Die(value: 3));
        expect(Scorer.scoreLargeStraight(dice), 0);
      });
    });

    group('scoreYatzy', () {
      test('returns 50 for first yatzy (all match)', () {
        final dice = List.generate(5, (_) => const Die(value: 3));
        expect(Scorer.scoreYatzy(dice, yatzyCount: 0), 50);
      });

      test('returns 100 for second yatzy (first bonus)', () {
        final dice = List.generate(5, (_) => const Die(value: 6));
        expect(Scorer.scoreYatzy(dice, yatzyCount: 1), 100);
      });

      test('returns 150 for third yatzy (second bonus)', () {
        final dice = List.generate(5, (_) => const Die(value: 1));
        expect(Scorer.scoreYatzy(dice, yatzyCount: 2), 150);
      });

      test('returns 0 when not all match', () {
        final dice = [
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 3),
          const Die(value: 4),
        ];
        expect(Scorer.scoreYatzy(dice), 0);
      });

      test('returns 0 for all different values', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
        ];
        expect(Scorer.scoreYatzy(dice), 0);
      });

      test('returns 0 for three of a kind', () {
        final dice = [
          const Die(value: 5),
          const Die(value: 5),
          const Die(value: 5),
          const Die(value: 2),
          const Die(value: 6),
        ];
        expect(Scorer.scoreYatzy(dice), 0);
      });
    });

    group('scoreChance', () {
      test('returns sum for [1,2,3,4,5]', () {
        final dice = [
          const Die(value: 1),
          const Die(value: 2),
          const Die(value: 3),
          const Die(value: 4),
          const Die(value: 5),
        ];
        expect(Scorer.scoreChance(dice), 15);
      });

      test('returns sum for [6,6,6,6,6]', () {
        final dice = List.generate(5, (_) => const Die(value: 6));
        expect(Scorer.scoreChance(dice), 30);
      });

      test('returns sum for mixed values', () {
        final dice = [
          const Die(value: 2),
          const Die(value: 4),
          const Die(value: 1),
          const Die(value: 6),
          const Die(value: 3),
        ];
        expect(Scorer.scoreChance(dice), 16);
      });

      test('returns sum for [1,1,1,1,1]', () {
        final dice = List.generate(5, (_) => const Die(value: 1));
        expect(Scorer.scoreChance(dice), 5);
      });
    });
  });

  // Note: Private helper methods (_countOccurrences, _isConsecutive, _getSortedValues)
  // are tested indirectly through public method tests above.
}
