import '../models/die.dart';

/// Scorer class for calculating Poker Dice game scores.
///
/// This class provides static methods for scoring all 13 Poker Dice categories
/// including:
///
/// **Upper Section** (scoring by die value):
/// - [scoreAces]: Sum of dice showing 1
/// - [scoreTwos]: Sum of dice showing 2
/// - [scoreThrees]: Sum of dice showing 3
/// - [scoreFours]: Sum of dice showing 4
/// - [scoreFives]: Sum of dice showing 5
/// - [scoreSixes]: Sum of dice showing 6
///
/// **Lower Section** (combination scoring):
/// - [scoreThreeOfKind]: Sum of all dice if 3+ match
/// - [scoreFourOfKind]: Sum of all dice if 4+ match
/// - [scoreFullHouse]: 25 points for 3+2 combination
/// - [scoreSmallStraight]: 30 points for 4 consecutive values
/// - [scoreLargeStraight]: 40 points for 5 consecutive values
/// - [scoreYatzy]: 50 points (plus bonuses) for all 5 matching
/// - [scoreChance]: Sum of all dice
///
/// All methods are static and do not require instantiation.
///
/// Example:
/// ```dart
/// final dice = [Die(value: 3), Die(value: 3), Die(value: 3), Die(value: 1), Die(value: 5)];
/// final score = Scorer.scoreThreeOfKind(dice); // Returns 15 (sum of all dice)
/// ```
class Scorer {
  /// Private constructor to prevent instantiation of this utility class.
  ///
  /// All methods in this class are static and do not require an instance.
  Scorer._();

  // ==================== UPPER SECTION ====================

  /// Scores the Aces category (upper section).
  ///
  /// Returns the sum of all dice showing 1.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// The sum of all dice with value 1.
  ///
  /// Example:
  /// ```dart
  /// scoreAces([Die(1), Die(1), Die(3), Die(4), Die(5)]); // Returns 2
  /// scoreAces([Die(2), Die(3), Die(4), Die(5), Die(6)]); // Returns 0
  /// ```
  static int scoreAces(List<Die> dice) {
    return dice
        .where((die) => die.value == 1)
        .fold(0, (sum, die) => sum + die.value);
  }

  /// Scores the Twos category (upper section).
  ///
  /// Returns the sum of all dice showing 2.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// The sum of all dice with value 2.
  ///
  /// Example:
  /// ```dart
  /// scoreTwos([Die(2), Die(2), Die(2), Die(5), Die(6)]); // Returns 6
  /// scoreTwos([Die(1), Die(3), Die(4), Die(5), Die(6)]); // Returns 0
  /// ```
  static int scoreTwos(List<Die> dice) {
    return dice
        .where((die) => die.value == 2)
        .fold(0, (sum, die) => sum + die.value);
  }

  /// Scores the Threes category (upper section).
  ///
  /// Returns the sum of all dice showing 3.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// The sum of all dice with value 3.
  ///
  /// Example:
  /// ```dart
  /// scoreThrees([Die(3), Die(3), Die(3), Die(1), Die(2)]); // Returns 9
  /// scoreThrees([Die(1), Die(2), Die(4), Die(5), Die(6)]); // Returns 0
  /// ```
  static int scoreThrees(List<Die> dice) {
    return dice
        .where((die) => die.value == 3)
        .fold(0, (sum, die) => sum + die.value);
  }

  /// Scores the Fours category (upper section).
  ///
  /// Returns the sum of all dice showing 4.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// The sum of all dice with value 4.
  ///
  /// Example:
  /// ```dart
  /// scoreFours([Die(4), Die(4), Die(1), Die(2), Die(3)]); // Returns 8
  /// scoreFours([Die(1), Die(2), Die(3), Die(5), Die(6)]); // Returns 0
  /// ```
  static int scoreFours(List<Die> dice) {
    return dice
        .where((die) => die.value == 4)
        .fold(0, (sum, die) => sum + die.value);
  }

  /// Scores the Fives category (upper section).
  ///
  /// Returns the sum of all dice showing 5.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// The sum of all dice with value 5.
  ///
  /// Example:
  /// ```dart
  /// scoreFives([Die(5), Die(5), Die(5), Die(1), Die(2)]); // Returns 15
  /// scoreFives([Die(1), Die(2), Die(3), Die(4), Die(6)]); // Returns 0
  /// ```
  static int scoreFives(List<Die> dice) {
    return dice
        .where((die) => die.value == 5)
        .fold(0, (sum, die) => sum + die.value);
  }

  /// Scores the Sixes category (upper section).
  ///
  /// Returns the sum of all dice showing 6.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// The sum of all dice with value 6.
  ///
  /// Example:
  /// ```dart
  /// scoreSixes([Die(6), Die(6), Die(6), Die(6), Die(1)]); // Returns 24
  /// scoreSixes([Die(1), Die(2), Die(3), Die(4), Die(5)]); // Returns 0
  /// ```
  static int scoreSixes(List<Die> dice) {
    return dice
        .where((die) => die.value == 6)
        .fold(0, (sum, die) => sum + die.value);
  }

  // ==================== LOWER SECTION ====================

  /// Scores the Three of a Kind category (lower section).
  ///
  /// Returns the sum of ALL dice if at least 3 dice show the same value,
  /// otherwise returns 0.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// Sum of all 5 dice if 3 or more show the same value, otherwise 0.
  ///
  /// Example:
  /// ```dart
  /// scoreThreeOfKind([Die(1), Die(2), Die(2), Die(2), Die(5)]); // Returns 12
  /// scoreThreeOfKind([Die(1), Die(2), Die(3), Die(4), Die(5)]); // Returns 0
  /// ```
  static int scoreThreeOfKind(List<Die> dice) {
    final counts = _countOccurrences(dice);
    if (counts.values.any((count) => count >= 3)) {
      return dice.fold(0, (sum, die) => sum + die.value);
    }
    return 0;
  }

  /// Scores the Four of a Kind category (lower section).
  ///
  /// Returns the sum of ALL dice if at least 4 dice show the same value,
  /// otherwise returns 0.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// Sum of all 5 dice if 4 or more show the same value, otherwise 0.
  ///
  /// Example:
  /// ```dart
  /// scoreFourOfKind([Die(1), Die(3), Die(3), Die(3), Die(3)]); // Returns 13
  /// scoreFourOfKind([Die(1), Die(2), Die(3), Die(4), Die(5)]); // Returns 0
  /// ```
  static int scoreFourOfKind(List<Die> dice) {
    final counts = _countOccurrences(dice);
    if (counts.values.any((count) => count >= 4)) {
      return dice.fold(0, (sum, die) => sum + die.value);
    }
    return 0;
  }

  /// Scores the Full House category (lower section).
  ///
  /// Returns 25 points if exactly 3 dice show one value and 2 dice show
  /// another value. Returns 0 otherwise.
  ///
  /// **Important:** 4 of a kind + 1 does NOT count as a full house.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// 25 for a valid full house (3+2 combination), otherwise 0.
  ///
  /// Example:
  /// ```dart
  /// scoreFullHouse([Die(2), Die(2), Die(2), Die(5), Die(5)]); // Returns 25
  /// scoreFullHouse([Die(3), Die(3), Die(3), Die(3), Die(1)]); // Returns 0
  /// ```
  static int scoreFullHouse(List<Die> dice) {
    final counts = _countOccurrences(dice);
    if (counts.length == 2 &&
        counts.containsValue(3) &&
        counts.containsValue(2)) {
      return 25;
    }
    return 0;
  }

  /// Scores the Small Straight category (lower section).
  ///
  /// Returns 30 points if 4 consecutive values are present among the dice.
  ///
  /// Valid small straights:
  /// - [1, 2, 3, 4] (with any fifth die)
  /// - [2, 3, 4, 5] (with any fifth die)
  /// - [3, 4, 5, 6] (with any fifth die)
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// 30 if 4 consecutive values exist, otherwise 0.
  ///
  /// Example:
  /// ```dart
  /// scoreSmallStraight([Die(1), Die(2), Die(3), Die(4), Die(6)]); // Returns 30
  /// scoreSmallStraight([Die(2), Die(3), Die(4), Die(5), Die(6)]); // Returns 30
  /// scoreSmallStraight([Die(1), Die(3), Die(4), Die(5), Die(6)]); // Returns 0
  /// ```
  static int scoreSmallStraight(List<Die> dice) {
    final sortedValues = _getSortedValues(dice);
    final uniqueValues = sortedValues.toSet().toList();

    // Check for 4 consecutive values starting from 1, 2, or 3
    for (int start = 1; start <= 3; start++) {
      if (uniqueValues.contains(start) &&
          uniqueValues.contains(start + 1) &&
          uniqueValues.contains(start + 2) &&
          uniqueValues.contains(start + 3)) {
        return 30;
      }
    }
    return 0;
  }

  /// Scores the Large Straight category (lower section).
  ///
  /// Returns 40 points if all 5 dice show consecutive values.
  ///
  /// Valid large straights:
  /// - [1, 2, 3, 4, 5]
  /// - [2, 3, 4, 5, 6]
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// 40 if all 5 dice are consecutive, otherwise 0.
  ///
  /// Example:
  /// ```dart
  /// scoreLargeStraight([Die(1), Die(2), Die(3), Die(4), Die(5)]); // Returns 40
  /// scoreLargeStraight([Die(6), Die(5), Die(4), Die(3), Die(2)]); // Returns 40
  /// scoreLargeStraight([Die(1), Die(2), Die(3), Die(4), Die(6)]); // Returns 0
  /// ```
  static int scoreLargeStraight(List<Die> dice) {
    final uniqueValues = dice.map((d) => d.value).toSet().toList()..sort();

    // Large straight requires exactly 5 unique consecutive values
    if (uniqueValues.length != 5) {
      return 0;
    }

    // Check if values are consecutive
    return _isConsecutive(uniqueValues) ? 40 : 0;
  }

  /// Scores the Yatzy category (lower section).
  ///
  /// Returns 50 points plus 50 points for each previous Yatzy if all 5 dice
  /// show the same value. Returns 0 otherwise.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  /// - [yatzyCount]: Number of previous Yatzy scores (defaults to 0).
  ///
  /// Returns:
  /// 50 + (yatzyCount * 50) if all 5 dice match, otherwise 0.
  ///
  /// Scoring progression:
  /// - First Yatzy: 50 points
  /// - Second Yatzy: 100 points
  /// - Third Yatzy: 150 points
  ///
  /// Example:
  /// ```dart
  /// scoreYatzy([Die(3), Die(3), Die(3), Die(3), Die(3)]); // Returns 50
  /// scoreYatzy([Die(6), Die(6), Die(6), Die(6), Die(6)], yatzyCount: 1); // Returns 100
  /// scoreYatzy([Die(1), Die(2), Die(3), Die(4), Die(5)]); // Returns 0
  /// ```
  static int scoreYatzy(List<Die> dice, {int yatzyCount = 0}) {
    final counts = _countOccurrences(dice);
    if (counts.values.any((count) => count == 5)) {
      return 50 + (yatzyCount * 50);
    }
    return 0;
  }

  /// Scores the Chance category (lower section).
  ///
  /// Returns the sum of all 5 dice regardless of their values or combinations.
  /// This is a safe scoring option when no better combination is available.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// The sum of all die values.
  ///
  /// Example:
  /// ```dart
  /// scoreChance([Die(1), Die(2), Die(3), Die(4), Die(5)]); // Returns 15
  /// scoreChance([Die(6), Die(6), Die(6), Die(6), Die(6)]); // Returns 30
  /// scoreChance([Die(1), Die(1), Die(2), Die(2), Die(3)]); // Returns 9
  /// ```
  static int scoreChance(List<Die> dice) {
    return dice.fold(0, (sum, die) => sum + die.value);
  }

  // ==================== PRIVATE HELPERS ====================

  /// Counts the occurrences of each die value (1-6).
  ///
  /// Parameters:
  /// - [dice]: The list of dice to count.
  ///
  /// Returns:
  /// A map where keys are die values (1-6) and values are their occurrence counts.
  ///
  /// Example:
  /// ```dart
  /// _countOccurrences([Die(1), Die(2), Die(2), Die(3), Die(3)]);
  /// // Returns {1: 1, 2: 2, 3: 2}
  /// ```
  static Map<int, int> _countOccurrences(List<Die> dice) {
    final counts = <int, int>{};
    for (final die in dice) {
      counts[die.value] = (counts[die.value] ?? 0) + 1;
    }
    return counts;
  }

  /// Checks if a list of integers is consecutive.
  ///
  /// Parameters:
  /// - [sortedValues]: A sorted list of integers to check.
  ///
  /// Returns:
  /// True if each value is exactly 1 more than the previous value.
  /// Returns true for lists with less than 2 elements.
  ///
  /// Example:
  /// ```dart
  /// _isConsecutive([1, 2, 3, 4]); // true
  /// _isConsecutive([2, 3, 4, 5]); // true
  /// _isConsecutive([1, 2, 4, 5]); // false
  /// _isConsecutive([1]); // true
  /// ```
  static bool _isConsecutive(List<int> sortedValues) {
    if (sortedValues.length < 2) {
      return true;
    }
    for (int i = 1; i < sortedValues.length; i++) {
      if (sortedValues[i] != sortedValues[i - 1] + 1) {
        return false;
      }
    }
    return true;
  }

  /// Returns a sorted list of die values.
  ///
  /// Parameters:
  /// - [dice]: The list of dice to extract values from.
  ///
  /// Returns:
  /// A list of die values sorted in ascending order.
  ///
  /// Example:
  /// ```dart
  /// _getSortedValues([Die(3), Die(1), Die(5), Die(2), Die(4)]);
  /// // Returns [1, 2, 3, 4, 5]
  /// ```
  static List<int> _getSortedValues(List<Die> dice) {
    final values = dice.map((die) => die.value).toList()..sort();
    return values;
  }
}
