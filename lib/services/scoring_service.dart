import '../models/dice.dart';
import '../models/score_category.dart';

/// Calculates scores for a given set of dice and a [ScoreCategory].
///
/// Returns 0 for combinations that do not qualify for the category.
class ScoringService {
  /// Calculates the score for [dice] in the given [category].
  int calculateScore(List<Dice> dice, ScoreCategory category) {
    switch (category) {
      // Upper section
      case ScoreCategory.aces:
      case ScoreCategory.twos:
      case ScoreCategory.threes:
      case ScoreCategory.fours:
      case ScoreCategory.fives:
      case ScoreCategory.sixes:
        return _scoreUpper(dice, category);

      // Lower section
      case ScoreCategory.threeOfAKind:
        return _scoreThreeOfAKind(dice);
      case ScoreCategory.fourOfAKind:
        return _scoreFourOfAKind(dice);
      case ScoreCategory.fullHouse:
        return _scoreFullHouse(dice);
      case ScoreCategory.smallStraight:
        return _scoreSmallStraight(dice);
      case ScoreCategory.largeStraight:
        return _scoreLargeStraight(dice);
      case ScoreCategory.yatzy:
        return _scoreYatzy(dice);
      case ScoreCategory.chance:
        return _scoreChance(dice);
    }
  }

  /// Counts occurrences of each die face value.
  Map<int, int> countDiceValues(List<Dice> dice) {
    final counts = <int, int>{};
    for (final die in dice) {
      counts[die.value] = (counts[die.value] ?? 0) + 1;
    }
    return counts;
  }

  /// Checks if [values] contains at least [count] consecutive integers.
  bool hasConsecutive(List<int> values, int count) {
    final sorted = List<int>.from(values)..sort();
    int consecutive = 1;
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i] == sorted[i - 1] + 1) {
        consecutive++;
        if (consecutive >= count) return true;
      } else {
        consecutive = 1;
      }
    }
    return consecutive >= count;
  }

  // -----------------------------------------------------------------------
  // Upper section
  // -----------------------------------------------------------------------

  int _scoreUpper(List<Dice> dice, ScoreCategory category) {
    final target = category.diceValue;
    if (target == null) return 0;
    int sum = 0;
    for (final die in dice) {
      if (die.value == target) {
        sum += target;
      }
    }
    return sum;
  }

  // -----------------------------------------------------------------------
  // Lower section
  // -----------------------------------------------------------------------

  int _scoreThreeOfAKind(List<Dice> dice) {
    final counts = countDiceValues(dice);
    if (counts.values.any((c) => c >= 3)) {
      return dice.fold(0, (sum, d) => sum + d.value);
    }
    return 0;
  }

  int _scoreFourOfAKind(List<Dice> dice) {
    final counts = countDiceValues(dice);
    if (counts.values.any((c) => c >= 4)) {
      return dice.fold(0, (sum, d) => sum + d.value);
    }
    return 0;
  }

  int _scoreFullHouse(List<Dice> dice) {
    final counts = countDiceValues(dice);
    final values = counts.values.toList();
    values.sort();
    // Full house: exactly [2, 3] counts (3 of one + 2 of another)
    if (values.length == 2 && values[0] == 2 && values[1] == 3) {
      return 25;
    }
    return 0;
  }

  int _scoreSmallStraight(List<Dice> dice) {
    final uniqueValues = countDiceValues(dice).keys.toList();
    if (hasConsecutive(uniqueValues, 4)) {
      return 30;
    }
    return 0;
  }

  int _scoreLargeStraight(List<Dice> dice) {
    final uniqueValues = countDiceValues(dice).keys.toList();
    if (hasConsecutive(uniqueValues, 5)) {
      return 40;
    }
    return 0;
  }

  int _scoreYatzy(List<Dice> dice) {
    // Yatzy requires 5 dice of the same non-zero value
    final counts = <int, int>{};
    for (final die in dice) {
      if (die.value > 0) {
        counts[die.value] = (counts[die.value] ?? 0) + 1;
      }
    }
    if (counts.values.any((c) => c == 5)) {
      return 50;
    }
    return 0;
  }

  int _scoreChance(List<Dice> dice) {
    return dice.fold(0, (sum, d) => sum + d.value);
  }
}
