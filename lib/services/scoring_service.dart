import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/dice_roll.dart';

/// Calculates scores for all Yatzy scoring categories.
class ScoringService {
  /// Sum of dice showing 1.
  int scoreOnes(DiceRoll roll) {
    return roll.countOccurrences(1) * 1;
  }

  /// Sum of dice showing 2.
  int scoreTwos(DiceRoll roll) {
    return roll.countOccurrences(2) * 2;
  }

  /// Sum of dice showing 3.
  int scoreThrees(DiceRoll roll) {
    return roll.countOccurrences(3) * 3;
  }

  /// Sum of dice showing 4.
  int scoreFours(DiceRoll roll) {
    return roll.countOccurrences(4) * 4;
  }

  /// Sum of dice showing 5.
  int scoreFives(DiceRoll roll) {
    return roll.countOccurrences(5) * 5;
  }

  /// Sum of dice showing 6.
  int scoreSixes(DiceRoll roll) {
    return roll.countOccurrences(6) * 6;
  }

  /// 3+ same value → sum ALL dice, else 0.
  int scoreThreeOfAKind(DiceRoll roll) {
    final hasThreeOfAKind = roll.dice.any(
      (die) => roll.countOccurrences(die.value) >= 3,
    );
    return hasThreeOfAKind ? roll.getValues().reduce((a, b) => a + b) : 0;
  }

  /// 4+ same value → sum ALL dice, else 0.
  int scoreFourOfAKind(DiceRoll roll) {
    final hasFourOfAKind = roll.dice.any(
      (die) => roll.countOccurrences(die.value) >= 4,
    );
    return hasFourOfAKind ? roll.getValues().reduce((a, b) => a + b) : 0;
  }

  /// Exactly 3+2 pattern → 25, else 0.
  int scoreFullHouse(DiceRoll roll) {
    final counts = _getCounts(roll);
    final values = counts.values.toList();
    values.sort();
    return values.length == 2 && values[0] == 2 && values[1] == 3 ? 25 : 0;
  }

  /// 4+ consecutive values → 30, else 0.
  int scoreSmallStraight(DiceRoll roll) {
    return _getLongestConsecutive(roll) >= 4 ? 30 : 0;
  }

  /// 5 consecutive (1-5 or 2-6) → 40, else 0.
  int scoreLargeStraight(DiceRoll roll) {
    return _getLongestConsecutive(roll) == 5 ? 40 : 0;
  }

  /// All 5 dice same → 50, else 0.
  int scoreYatzy(DiceRoll roll) {
    return roll.dice.every((die) => die.value == roll.dice[0].value) ? 50 : 0;
  }

  /// Sum of ALL dice.
  int scoreChance(DiceRoll roll) {
    return roll.getValues().reduce((a, b) => a + b);
  }

  /// Returns 35 if upperSectionTotal >= 63, else 0.
  int calculateBonus(int upperSectionTotal) {
    return upperSectionTotal >= 63 ? 35 : 0;
  }

  /// Scores the given [category] for the [roll].
  int scoreCategory(Category category, DiceRoll roll) {
    switch (category) {
      case Category.ones:
        return scoreOnes(roll);
      case Category.twos:
        return scoreTwos(roll);
      case Category.threes:
        return scoreThrees(roll);
      case Category.fours:
        return scoreFours(roll);
      case Category.fives:
        return scoreFives(roll);
      case Category.sixes:
        return scoreSixes(roll);
      case Category.threeOfAKind:
        return scoreThreeOfAKind(roll);
      case Category.fourOfAKind:
        return scoreFourOfAKind(roll);
      case Category.fullHouse:
        return scoreFullHouse(roll);
      case Category.smallStraight:
        return scoreSmallStraight(roll);
      case Category.largeStraight:
        return scoreLargeStraight(roll);
      case Category.yatzy:
        return scoreYatzy(roll);
      case Category.house:
        return scoreFullHouse(roll);
      case Category.chance:
        return scoreChance(roll);
    }
  }

  /// Returns a map of die value to count of occurrences.
  Map<int, int> _getCounts(DiceRoll roll) {
    final counts = <int, int>{};
    for (final die in roll.dice) {
      counts[die.value] = (counts[die.value] ?? 0) + 1;
    }
    return counts;
  }

  /// Returns the length of the longest consecutive sequence.
  int _getLongestConsecutive(DiceRoll roll) {
    final unique = roll.getValues().toSet().toList()..sort();

    if (unique.isEmpty) return 0;

    var maxRun = 1;
    var currentRun = 1;

    for (var i = 1; i < unique.length; i++) {
      if (unique[i] == unique[i - 1] + 1) {
        currentRun++;
        maxRun = currentRun > maxRun ? currentRun : maxRun;
      } else {
        currentRun = 1;
      }
    }

    return maxRun;
  }
}
