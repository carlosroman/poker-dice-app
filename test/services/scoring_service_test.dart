import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/services/scoring_service.dart';

void main() {
  late ScoringService service;

  setUp(() {
    service = ScoringService();
  });

  // -----------------------------------------------------------------------
  // Helper
  // -----------------------------------------------------------------------

  List<Dice> dice(List<int> values) {
    return values.map((v) => Dice(value: v)).toList();
  }

  // -----------------------------------------------------------------------
  // countDiceValues
  // -----------------------------------------------------------------------

  group('countDiceValues', () {
    test('counts each face value correctly', () {
      final counts = service.countDiceValues(dice([1, 1, 3, 5, 5]));
      expect(counts, equals({1: 2, 3: 1, 5: 2}));
    });

    test('returns empty map for empty list', () {
      expect(service.countDiceValues([]), isEmpty);
    });
  });

  // -----------------------------------------------------------------------
  // hasConsecutive
  // -----------------------------------------------------------------------

  group('hasConsecutive', () {
    test('detects 4 consecutive values', () {
      expect(service.hasConsecutive([1, 2, 3, 4, 6], 4), isTrue);
    });

    test('detects 5 consecutive values', () {
      expect(service.hasConsecutive([1, 2, 3, 4, 5], 5), isTrue);
      expect(service.hasConsecutive([2, 3, 4, 5, 6], 5), isTrue);
    });

    test('returns false when not enough consecutive', () {
      expect(service.hasConsecutive([1, 3, 5, 6, 2], 4), isFalse);
    });

    test('handles unsorted input', () {
      expect(service.hasConsecutive([5, 2, 4, 3, 1], 5), isTrue);
    });
  });

  // -----------------------------------------------------------------------
  // Upper section
  // -----------------------------------------------------------------------

  group('Upper section', () {
    test('aces scores sum of 1s', () {
      expect(
        service.calculateScore(dice([1, 1, 3, 5, 6]), ScoreCategory.aces),
        2,
      );
    });

    test('twos scores sum of 2s', () {
      expect(
        service.calculateScore(dice([2, 2, 2, 5, 6]), ScoreCategory.twos),
        6,
      );
    });

    test('threes scores sum of 3s', () {
      expect(
        service.calculateScore(dice([1, 3, 3, 5, 6]), ScoreCategory.threes),
        6,
      );
    });

    test('fours scores sum of 4s', () {
      expect(
        service.calculateScore(dice([1, 2, 4, 4, 6]), ScoreCategory.fours),
        8,
      );
    });

    test('fives scores sum of 5s', () {
      expect(
        service.calculateScore(dice([1, 2, 5, 5, 5]), ScoreCategory.fives),
        15,
      );
    });

    test('sixes scores sum of 6s', () {
      expect(
        service.calculateScore(dice([6, 6, 6, 6, 6]), ScoreCategory.sixes),
        30,
      );
    });

    test('returns 0 when no matching dice', () {
      expect(
        service.calculateScore(dice([2, 3, 4, 5, 6]), ScoreCategory.aces),
        0,
      );
    });
  });

  // -----------------------------------------------------------------------
  // Three of a Kind
  // -----------------------------------------------------------------------

  group('Three of a Kind', () {
    test('scores sum of all dice with exactly 3 matching', () {
      expect(
        service.calculateScore(
          dice([3, 3, 3, 5, 6]),
          ScoreCategory.threeOfAKind,
        ),
        20,
      );
    });

    test('scores sum of all dice with 4 matching', () {
      expect(
        service.calculateScore(
          dice([4, 4, 4, 4, 2]),
          ScoreCategory.threeOfAKind,
        ),
        18,
      );
    });

    test('scores sum of all dice with 5 matching', () {
      expect(
        service.calculateScore(
          dice([2, 2, 2, 2, 2]),
          ScoreCategory.threeOfAKind,
        ),
        10,
      );
    });

    test('returns 0 with only 2 matching', () {
      expect(
        service.calculateScore(
          dice([1, 1, 3, 4, 5]),
          ScoreCategory.threeOfAKind,
        ),
        0,
      );
    });

    test('returns 0 with all different', () {
      expect(
        service.calculateScore(
          dice([1, 2, 3, 4, 5]),
          ScoreCategory.threeOfAKind,
        ),
        0,
      );
    });
  });

  // -----------------------------------------------------------------------
  // Four of a Kind
  // -----------------------------------------------------------------------

  group('Four of a Kind', () {
    test('scores sum of all dice with exactly 4 matching', () {
      expect(
        service.calculateScore(
          dice([5, 5, 5, 5, 2]),
          ScoreCategory.fourOfAKind,
        ),
        22,
      );
    });

    test('scores sum of all dice with 5 matching', () {
      expect(
        service.calculateScore(
          dice([3, 3, 3, 3, 3]),
          ScoreCategory.fourOfAKind,
        ),
        15,
      );
    });

    test('returns 0 with only 3 matching', () {
      expect(
        service.calculateScore(
          dice([2, 2, 2, 4, 5]),
          ScoreCategory.fourOfAKind,
        ),
        0,
      );
    });
  });

  // -----------------------------------------------------------------------
  // Full House
  // -----------------------------------------------------------------------

  group('Full House', () {
    test('scores 25 with 3 of one and 2 of another', () {
      expect(
        service.calculateScore(dice([1, 1, 4, 4, 4]), ScoreCategory.fullHouse),
        25,
      );
    });

    test('scores 25 regardless of face values', () {
      expect(
        service.calculateScore(dice([6, 6, 6, 2, 2]), ScoreCategory.fullHouse),
        25,
      );
    });

    test('returns 0 with 4 of a kind', () {
      expect(
        service.calculateScore(dice([3, 3, 3, 3, 5]), ScoreCategory.fullHouse),
        0,
      );
    });

    test('returns 0 with 5 of a kind (Yatzy)', () {
      expect(
        service.calculateScore(dice([5, 5, 5, 5, 5]), ScoreCategory.fullHouse),
        0,
      );
    });

    test('returns 0 with two pairs', () {
      expect(
        service.calculateScore(dice([1, 1, 3, 3, 5]), ScoreCategory.fullHouse),
        0,
      );
    });
  });

  // -----------------------------------------------------------------------
  // Small Straight
  // -----------------------------------------------------------------------

  group('Small Straight', () {
    test('scores 30 with 1-2-3-4-6', () {
      expect(
        service.calculateScore(
          dice([1, 2, 3, 4, 6]),
          ScoreCategory.smallStraight,
        ),
        30,
      );
    });

    test('scores 30 with 2-3-4-5-1', () {
      expect(
        service.calculateScore(
          dice([1, 2, 3, 4, 5]),
          ScoreCategory.smallStraight,
        ),
        30,
      );
    });

    test('scores 30 with 2-3-4-5-6', () {
      expect(
        service.calculateScore(
          dice([2, 3, 4, 5, 6]),
          ScoreCategory.smallStraight,
        ),
        30,
      );
    });

    test('returns 0 with only 3 consecutive', () {
      expect(
        service.calculateScore(
          dice([1, 2, 3, 5, 6]),
          ScoreCategory.smallStraight,
        ),
        0,
      );
    });

    test('returns 0 with no consecutive', () {
      expect(
        service.calculateScore(
          dice([1, 1, 3, 5, 6]),
          ScoreCategory.smallStraight,
        ),
        0,
      );
    });
  });

  // -----------------------------------------------------------------------
  // Large Straight
  // -----------------------------------------------------------------------

  group('Large Straight', () {
    test('scores 40 with 1-2-3-4-5', () {
      expect(
        service.calculateScore(
          dice([1, 2, 3, 4, 5]),
          ScoreCategory.largeStraight,
        ),
        40,
      );
    });

    test('scores 40 with 2-3-4-5-6', () {
      expect(
        service.calculateScore(
          dice([2, 3, 4, 5, 6]),
          ScoreCategory.largeStraight,
        ),
        40,
      );
    });

    test('returns 0 with only 4 consecutive', () {
      expect(
        service.calculateScore(
          dice([1, 2, 3, 4, 6]),
          ScoreCategory.largeStraight,
        ),
        0,
      );
    });
  });

  // -----------------------------------------------------------------------
  // Yatzy
  // -----------------------------------------------------------------------

  group('Yatzy', () {
    test('scores 50 with all 1s', () {
      expect(
        service.calculateScore(dice([1, 1, 1, 1, 1]), ScoreCategory.yatzy),
        50,
      );
    });

    test('scores 50 with all 6s', () {
      expect(
        service.calculateScore(dice([6, 6, 6, 6, 6]), ScoreCategory.yatzy),
        50,
      );
    });

    test('returns 0 with 4 matching', () {
      expect(
        service.calculateScore(dice([4, 4, 4, 4, 2]), ScoreCategory.yatzy),
        0,
      );
    });
  });

  // -----------------------------------------------------------------------
  // Chance
  // -----------------------------------------------------------------------

  group('Chance', () {
    test('scores sum of all dice', () {
      expect(
        service.calculateScore(dice([1, 3, 4, 5, 6]), ScoreCategory.chance),
        19,
      );
    });

    test('scores minimum (all 1s)', () {
      expect(
        service.calculateScore(dice([1, 1, 1, 1, 1]), ScoreCategory.chance),
        5,
      );
    });

    test('scores maximum (all 6s)', () {
      expect(
        service.calculateScore(dice([6, 6, 6, 6, 6]), ScoreCategory.chance),
        30,
      );
    });
  });
}
