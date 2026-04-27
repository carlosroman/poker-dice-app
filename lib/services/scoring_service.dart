import '../models/category.dart';
import '../models/dice_roll.dart';
import '../models/die.dart';

/// Service responsible for calculating scores for all 14 Yatzy categories.
///
/// This class provides methods to score dice rolls according to Yatzy rules:
/// - Upper Section: Sum of specific dice values (ones through sixes)
/// - Lower Section: Pattern-based scoring (three of a kind, straights, etc.)
///
/// Example usage:
/// ```dart
/// final service = ScoringService();
/// final dice = DiceRoll.fromValues([1, 2, 3, 4, 5]);
/// final score = service.score(Category.smallStraight, dice); // Returns 30
/// ```
// ignore_for_file: constant_identifier_names

class ScoringService {
  /// Constant for upper section target score to qualify for bonus.
  static const int UPPER_SECTION_TARGET = 63;

  /// Bonus points awarded when upper section sum >= 63.
  static const int BONUS_POINTS = 35;

  /// Fixed points for a Full House (3 of one value + 2 of another).
  static const int FULL_HOUSE_POINTS = 25;

  /// Fixed points for a Small Straight (4 or 5 consecutive values).
  static const int SMALL_STRAIGHT_POINTS = 30;

  /// Fixed points for a Large Straight (5 consecutive values).
  static const int LARGE_STRAIGHT_POINTS = 40;

  /// Fixed points for Yatzy (all 5 dice the same).
  static const int YATZY_POINTS = 50;

  /// Calculates the score for the given [category] and [dice].
  ///
  /// Returns the score based on the Yatzy rules for the specified category.
  /// Returns 0 if the dice combination does not qualify for the category.
  ///
  /// Throws [ArgumentError] if [category] is [Category.bonus] as bonus
  /// is calculated separately based on upper section sum.
  int score(Category category, DiceRoll dice) {
    switch (category) {
      case Category.ones:
        return scoreOnes(dice);
      case Category.twos:
        return scoreTwos(dice);
      case Category.threes:
        return scoreThrees(dice);
      case Category.fours:
        return scoreFours(dice);
      case Category.fives:
        return scoreFives(dice);
      case Category.sixes:
        return scoreSixes(dice);
      case Category.threeOfAKind:
        return scoreThreeOfAKind(dice);
      case Category.fourOfAKind:
        return scoreFourOfAKind(dice);
      case Category.fullHouse:
        return scoreFullHouse(dice);
      case Category.smallStraight:
        return scoreSmallStraight(dice);
      case Category.largeStraight:
        return scoreLargeStraight(dice);
      case Category.yatzy:
        return scoreYatzy(dice);
      case Category.chance:
        return scoreChance(dice);
      case Category.bonus:
        throw ArgumentError('Bonus category must be calculated separately');
    }
  }

  /// Calculates score for the Ones category.
  ///
  /// Returns the sum of all dice showing 1.
  /// Returns 0 if no dice show 1.
  int scoreOnes(DiceRoll dice) {
    return _scoreByValue(dice, 1);
  }

  /// Calculates score for the Twos category.
  ///
  /// Returns the sum of all dice showing 2.
  /// Returns 0 if no dice show 2.
  int scoreTwos(DiceRoll dice) {
    return _scoreByValue(dice, 2);
  }

  /// Calculates score for the Threes category.
  ///
  /// Returns the sum of all dice showing 3.
  /// Returns 0 if no dice show 3.
  int scoreThrees(DiceRoll dice) {
    return _scoreByValue(dice, 3);
  }

  /// Calculates score for the Fours category.
  ///
  /// Returns the sum of all dice showing 4.
  /// Returns 0 if no dice show 4.
  int scoreFours(DiceRoll dice) {
    return _scoreByValue(dice, 4);
  }

  /// Calculates score for the Fives category.
  ///
  /// Returns the sum of all dice showing 5.
  /// Returns 0 if no dice show 5.
  int scoreFives(DiceRoll dice) {
    return _scoreByValue(dice, 5);
  }

  /// Calculates score for the Sixes category.
  ///
  /// Returns the sum of all dice showing 6.
  /// Returns 0 if no dice show 6.
  int scoreSixes(DiceRoll dice) {
    return _scoreByValue(dice, 6);
  }

  /// Calculates score for Three of a Kind.
  ///
  /// Returns the sum of ALL dice if at least 3 dice have the same value.
  /// Returns 0 if no value appears 3 or more times.
  int scoreThreeOfAKind(DiceRoll dice) {
    final Map<int, int> counts = dice.getDiceCounts();
    for (final int count in counts.values) {
      if (count >= 3) {
        return dice.sumAllDice();
      }
    }
    return 0;
  }

  /// Calculates score for Four of a Kind.
  ///
  /// Returns the sum of ALL dice if at least 4 dice have the same value.
  /// Returns 0 if no value appears 4 or more times.
  int scoreFourOfAKind(DiceRoll dice) {
    final Map<int, int> counts = dice.getDiceCounts();
    for (final int count in counts.values) {
      if (count >= 4) {
        return dice.sumAllDice();
      }
    }
    return 0;
  }

  /// Calculates score for Full House.
  ///
  /// Returns 25 points if there is exactly 3 of one value AND 2 of another.
  /// Returns 0 otherwise (including 4+1 or 5-of-a-kind combinations).
  int scoreFullHouse(DiceRoll dice) {
    final Map<int, int> counts = dice.getDiceCounts();
    bool hasThree = false;
    bool hasTwo = false;

    for (final int count in counts.values) {
      if (count == 3) {
        hasThree = true;
      } else if (count == 2) {
        hasTwo = true;
      }
    }

    return (hasThree && hasTwo) ? FULL_HOUSE_POINTS : 0;
  }

  /// Calculates score for Small Straight.
  ///
  /// Returns 30 points if there are 4 or 5 consecutive values.
  /// Examples: [1,2,3,4,x], [2,3,4,5,x], [3,4,5,6,x], or any straight with 5 values.
  /// Returns 0 otherwise.
  int scoreSmallStraight(DiceRoll dice) {
    return _hasConsecutiveValues(dice, 4) ? SMALL_STRAIGHT_POINTS : 0;
  }

  /// Calculates score for Large Straight.
  ///
  /// Returns 40 points if there are exactly 5 consecutive values.
  /// Valid combinations: [1,2,3,4,5] or [2,3,4,5,6].
  /// Returns 0 otherwise.
  int scoreLargeStraight(DiceRoll dice) {
    return _hasConsecutiveValues(dice, 5) ? LARGE_STRAIGHT_POINTS : 0;
  }

  /// Calculates score for Yatzy.
  ///
  /// Returns 50 points if all 5 dice show the same value.
  /// Returns 0 otherwise.
  int scoreYatzy(DiceRoll dice) {
    return _isYatzy(dice) ? YATZY_POINTS : 0;
  }

  /// Calculates score for Chance.
  ///
  /// Returns the sum of all dice, regardless of combination.
  int scoreChance(DiceRoll dice) {
    return dice.sumAllDice();
  }

  /// Calculates the bonus based on upper section sum.
  ///
  /// Returns [BONUS_POINTS] (35) if the sum of upper section scores >= [UPPER_SECTION_TARGET] (63).
  /// Returns 0 otherwise.
  int calculateBonus(int upperSectionSum) {
    return upperSectionSum >= UPPER_SECTION_TARGET ? BONUS_POINTS : 0;
  }

  /// Helper method to score upper section categories.
  ///
  /// Returns the sum of all dice showing the specified [value].
  int _scoreByValue(DiceRoll dice, int value) {
    int count = dice.countOccurrences(value);
    return count * value;
  }

  /// Checks if the dice contain at least [count] consecutive values.
  ///
  /// For example, with count=4, returns true if there are 4 or 5 consecutive values.
  /// Returns false if there are fewer than [count] consecutive values.
  bool _hasConsecutiveValues(DiceRoll dice, int count) {
    final List<Die> sorted = dice.sortedDice;
    int consecutiveCount = 1;
    int maxConsecutive = 1;

    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].value == sorted[i - 1].value + 1) {
        consecutiveCount++;
        if (consecutiveCount > maxConsecutive) {
          maxConsecutive = consecutiveCount;
        }
      } else if (sorted[i].value != sorted[i - 1].value) {
        // Reset only if it's a different value (not a duplicate)
        consecutiveCount = 1;
      }
      // If duplicate value, keep the same consecutiveCount
    }

    return maxConsecutive >= count;
  }

  /// Checks if all 5 dice show the same value (Yatzy).
  bool _isYatzy(DiceRoll dice) {
    final int firstValue = dice.dice[0].value;
    for (int i = 1; i < dice.dice.length; i++) {
      if (dice.dice[i].value != firstValue) {
        return false;
      }
    }
    return true;
  }
}
