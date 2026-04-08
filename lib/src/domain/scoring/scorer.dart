import '../models/score_category.dart';

/// Scorer class for Yatzy dice game scoring logic.
///
/// Provides static methods for calculating scores for all categories
/// in the Yatzy dice game.
class Scorer {
  /// Prevents instantiation of Scorer class.
  Scorer._();

  /// Calculates the score for the upper section categories (Aces through Sixes).
  ///
  /// Returns the sum of dice values that match [category].
  /// For example, if category is [ScoreCategory.aces], returns sum of all 1s.
  static int calculateUpperScore(ScoreCategory category, List<int> dice) {
    if (category.section != ScoreSection.upper) {
      throw ArgumentError('Category must be from upper section');
    }

    switch (category) {
      case ScoreCategory.aces:
        return scoreAces(dice);
      case ScoreCategory.twos:
        return scoreTwos(dice);
      case ScoreCategory.threes:
        return scoreThrees(dice);
      case ScoreCategory.fours:
        return scoreFours(dice);
      case ScoreCategory.fives:
        return scoreFives(dice);
      case ScoreCategory.sixes:
        return scoreSixes(dice);
      default:
        throw ArgumentError('Invalid upper section category');
    }
  }

  /// Calculates the score for the lower section categories.
  static int calculateLowerScore(ScoreCategory category, List<int> dice) {
    if (category.section != ScoreSection.lower) {
      throw ArgumentError('Category must be from lower section');
    }

    switch (category) {
      case ScoreCategory.threeOfKind:
        return scoreThreeOfKind(dice);
      case ScoreCategory.fourOfKind:
        return scoreFourOfKind(dice);
      case ScoreCategory.fullHouse:
        return scoreFullHouse(dice);
      case ScoreCategory.smallStraight:
        return scoreSmallStraight(dice);
      case ScoreCategory.largeStraight:
        return scoreLargeStraight(dice);
      case ScoreCategory.yatzy:
        return scoreYatzy(dice);
      case ScoreCategory.chance:
        return scoreChance(dice);
      default:
        throw ArgumentError('Invalid lower section category');
    }
  }

  /// Returns true if the dice contain a Yatzy (all 5 dice the same).
  static bool isYatzy(List<int> dice) {
    if (dice.isEmpty) return false;
    final first = dice.first;
    return dice.every((die) => die == first);
  }

  /// Calculates the score for Aces category.
  ///
  /// Returns the sum of all dice showing 1.
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns sum of dice showing 1
  static int scoreAces(List<int> dice) {
    return dice.where((die) => die == 1).fold(0, (sum, die) => sum + die);
  }

  /// Calculates the score for Twos category.
  ///
  /// Returns the sum of all dice showing 2.
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns sum of dice showing 2
  static int scoreTwos(List<int> dice) {
    return dice.where((die) => die == 2).fold(0, (sum, die) => sum + die);
  }

  /// Calculates the score for Threes category.
  ///
  /// Returns the sum of all dice showing 3.
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns sum of dice showing 3
  static int scoreThrees(List<int> dice) {
    return dice.where((die) => die == 3).fold(0, (sum, die) => sum + die);
  }

  /// Calculates the score for Fours category.
  ///
  /// Returns the sum of all dice showing 4.
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns sum of dice showing 4
  static int scoreFours(List<int> dice) {
    return dice.where((die) => die == 4).fold(0, (sum, die) => sum + die);
  }

  /// Calculates the score for Fives category.
  ///
  /// Returns the sum of all dice showing 5.
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns sum of dice showing 5
  static int scoreFives(List<int> dice) {
    return dice.where((die) => die == 5).fold(0, (sum, die) => sum + die);
  }

  /// Calculates the score for Sixes category.
  ///
  /// Returns the sum of all dice showing 6.
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns sum of dice showing 6
  static int scoreSixes(List<int> dice) {
    return dice.where((die) => die == 6).fold(0, (sum, die) => sum + die);
  }

  /// Calculates the score for Three of a Kind category.
  ///
  /// Returns the sum of ALL dice if 3 or more dice show the same value.
  /// Returns 0 otherwise.
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns sum of all dice if 3+ match, otherwise 0
  static int scoreThreeOfKind(List<int> dice) {
    final counts = _countOccurrences(dice);
    if (counts.values.any((count) => count >= 3)) {
      return dice.fold(0, (sum, die) => sum + die);
    }
    return 0;
  }

  /// Calculates the score for Four of a Kind category.
  ///
  /// Returns the sum of ALL dice if 4 or more dice show the same value.
  /// Returns 0 otherwise.
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns sum of all dice if 4+ match, otherwise 0
  static int scoreFourOfKind(List<int> dice) {
    final counts = _countOccurrences(dice);
    if (counts.values.any((count) => count >= 4)) {
      return dice.fold(0, (sum, die) => sum + die);
    }
    return 0;
  }

  /// Calculates the score for Full House category.
  ///
  /// Returns 25 if exactly 3 dice show one value and 2 dice show another value.
  /// Returns 0 otherwise (note: 4+1 does NOT count as Full House).
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns 25 if valid Full House, otherwise 0
  static int scoreFullHouse(List<int> dice) {
    final counts = _countOccurrences(dice);
    final values = counts.values.toList()..sort();
    // Full House: exactly 3 of one value + 2 of another
    if (values.length == 2 && values[0] == 2 && values[1] == 3) {
      return 25;
    }
    return 0;
  }

  /// Calculates the score for Small Straight category.
  ///
  /// Returns 30 if there are 4 consecutive values (1-2-3-4, 2-3-4-5, or 3-4-5-6).
  /// Returns 0 otherwise.
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns 30 if small straight, otherwise 0
  static int scoreSmallStraight(List<int> dice) {
    final sorted = List<int>.from(dice)..sort();
    final unique = sorted.toSet().toList()..sort();

    // Check for 4 consecutive values
    for (int i = 0; i <= unique.length - 4; i++) {
      final subList = unique.sublist(i, i + 4);
      if (_isConsecutive(subList)) {
        return 30;
      }
    }
    return 0;
  }

  /// Calculates the score for Large Straight category.
  ///
  /// Returns 40 if there are 5 consecutive values (1-2-3-4-5 or 2-3-4-5-6).
  /// Returns 0 otherwise.
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns 40 if large straight, otherwise 0
  static int scoreLargeStraight(List<int> dice) {
    if (dice.length != 5) {
      return 0;
    }
    final sorted = List<int>.from(dice)..sort();
    if (_isConsecutive(sorted)) {
      return 40;
    }
    return 0;
  }

  /// Calculates the score for Yatzy category.
  ///
  /// Returns 50 + (yatzyCount * 50) if all 5 dice show the same value.
  /// Returns 0 otherwise.
  ///
  /// [dice] - List of dice values (1-6)
  /// [yatzyCount] - Number of previous Yatzy scored (0 for first Yatzy)
  /// Returns 50 + (yatzyCount * 50) if Yatzy, otherwise 0
  static int scoreYatzy(List<int> dice, {int yatzyCount = 0}) {
    final counts = _countOccurrences(dice);
    if (counts.values.any((count) => count == 5)) {
      return 50 + (yatzyCount * 50);
    }
    return 0;
  }

  /// Calculates the score for Chance category.
  ///
  /// Returns the sum of all dice.
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns sum of all dice
  static int scoreChance(List<int> dice) {
    return dice.fold(0, (sum, die) => sum + die);
  }

  /// Helper method to count occurrences of each die value.
  ///
  /// [dice] - List of dice values (1-6)
  /// Returns a map with die value as key and count as value
  static Map<int, int> _countOccurrences(List<int> dice) {
    final counts = <int, int>{};
    for (final die in dice) {
      counts[die] = (counts[die] ?? 0) + 1;
    }
    return counts;
  }

  /// Helper method to check if sorted dice are consecutive.
  ///
  /// [sortedDice] - List of sorted dice values
  /// Returns true if values are consecutive (each value is 1 more than previous)
  static bool _isConsecutive(List<int> sortedDice) {
    if (sortedDice.isEmpty || sortedDice.length == 1) {
      return false;
    }
    for (int i = 1; i < sortedDice.length; i++) {
      if (sortedDice[i] != sortedDice[i - 1] + 1) {
        return false;
      }
    }
    return true;
  }
}
