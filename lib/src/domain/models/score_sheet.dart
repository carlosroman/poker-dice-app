import 'die.dart';
import 'score_category.dart';

/// Represents a complete score sheet for a Poker Dice game.
///
/// The [ScoreSheet] tracks scores for all 13 categories and calculates
/// totals including the upper section bonus. It manages the scoring
/// state throughout the game.
///
/// **Features:**
/// - Tracks all 13 category scores (null = not yet scored)
/// - Calculates upper section total and bonus (35 points if >= 63)
/// - Calculates lower section total
/// - Computes grand total including bonus
/// - Tracks Yatzy count for bonus accumulation
///
/// **Bonus Rule:**
/// If the upper section total is 63 or more (all dice values 1-6 scored
/// at least three times each), a bonus of 35 points is added.
///
/// Example:
/// ```dart
/// final sheet = ScoreSheet();
/// sheet.score(ScoreCategory.aces, [Die(value: 1), Die(value: 1), ...]);
/// final total = sheet.getTotal(); // Includes bonus if applicable
/// ```
class ScoreSheet {
  /// Map of scores for each category.
  ///
  /// A value of `null` indicates the category has not been scored yet.
  /// Once scored, the value contains the points awarded for that category.
  final Map<ScoreCategory, int?> scores;

  /// Tracks total number of Yatzy rolls for bonus calculation.
  ///
  /// Each Yatzy scored adds 50 points plus an additional 50 points
  /// for each previous Yatzy. For example:
  /// - First Yatzy: 50 points
  /// - Second Yatzy: 100 points
  /// - Third Yatzy: 150 points
  final int yatzyCount;

  /// Creates a new [ScoreSheet] with all categories unscored.
  ///
  /// Parameters:
  /// - [yatzyCount]: Initial Yatzy count (defaults to 0).
  ///
  /// Example:
  /// ```dart
  /// final sheet = ScoreSheet(); // All categories null, yatzyCount: 0
  /// final sheet2 = ScoreSheet(yatzyCount: 1); // Starting with 1 Yatzy
  /// ```
  ScoreSheet({this.yatzyCount = 0})
    : scores = {for (final category in ScoreCategory.values) category: null};

  /// Creates a copy of this [ScoreSheet] with optional updates.
  ///
  /// Parameters:
  /// - [scores]: New score map (defaults to current scores if null).
  /// - [yatzyCount]: New Yatzy count (defaults to current count if null).
  ///
  /// Example:
  /// ```dart
  /// final copy = ScoreSheet.copyWith(
  ///   scores: {...sheet.scores},
  ///   yatzyCount: sheet.yatzyCount + 1,
  /// );
  /// ```
  ScoreSheet.copyWith({Map<ScoreCategory, int?>? scores, int? yatzyCount})
    : scores = scores != null ? Map.from(scores) : {},
      yatzyCount = yatzyCount ?? 0;

  /// Calculates and stores the score for a given [category].
  ///
  /// This method scores the specified category using the current dice values
  /// and stores the result. Once scored, a category cannot be rescored.
  ///
  /// Parameters:
  /// - [category]: The category to score.
  /// - [dice]: The list of exactly 5 dice to score.
  ///
  /// Returns:
  /// The calculated score for the category.
  ///
  /// Throws:
  /// - [StateError]: If the category is already scored.
  ///
  /// Example:
  /// ```dart
  /// final sheet = ScoreSheet();
  /// final dice = [Die(value: 1), Die(value: 1), Die(value: 3), Die(value: 4), Die(value: 5)];
  /// final score = sheet.score(ScoreCategory.aces, dice); // Returns 2
  /// ```
  int score(ScoreCategory category, List<Die> dice) {
    if (isCategoryScored(category)) {
      throw StateError('Category ${category.displayName} is already scored.');
    }

    final calculatedScore = _calculateScore(category, dice);
    scores[category] = calculatedScore;

    return calculatedScore;
  }

  /// Calculates the score for a specific [category] based on [dice].
  ///
  /// This private method dispatches to the appropriate scoring method
  /// based on the category type.
  ///
  /// Parameters:
  /// - [category]: The category to score.
  /// - [dice]: The list of 5 dice to score.
  ///
  /// Returns:
  /// The calculated score (0 if the combination doesn't match).
  int _calculateScore(ScoreCategory category, List<Die> dice) {
    switch (category) {
      case ScoreCategory.aces:
        return _scoreUpper(dice, 1);
      case ScoreCategory.twos:
        return _scoreUpper(dice, 2);
      case ScoreCategory.threes:
        return _scoreUpper(dice, 3);
      case ScoreCategory.fours:
        return _scoreUpper(dice, 4);
      case ScoreCategory.fives:
        return _scoreUpper(dice, 5);
      case ScoreCategory.sixes:
        return _scoreUpper(dice, 6);
      case ScoreCategory.threeOfKind:
        return _scoreThreeOfKind(dice);
      case ScoreCategory.fourOfKind:
        return _scoreFourOfKind(dice);
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

  /// Scores upper section categories (Aces through Sixes).
  ///
  /// Returns the sum of all dice showing the specified [value].
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice.
  /// - [value]: The die value to count (1-6).
  ///
  /// Example:
  /// ```dart
  /// _scoreUpper([Die(1), Die(1), Die(3)], 1); // Returns 2
  /// _scoreUpper([Die(2), Die(2), Die(5)], 2); // Returns 4
  /// ```
  int _scoreUpper(List<Die> dice, int value) {
    return dice
        .where((die) => die.value == value)
        .fold(0, (sum, die) => sum + die.value);
  }

  /// Scores Three of a Kind: sum of all dice if 3+ match, else 0.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice.
  ///
  /// Returns:
  /// Sum of all dice if at least 3 dice show the same value, otherwise 0.
  ///
  /// Example:
  /// ```dart
  /// _scoreThreeOfKind([Die(1), Die(2), Die(2), Die(2), Die(5)]); // Returns 12
  /// _scoreThreeOfKind([Die(1), Die(2), Die(3), Die(4), Die(5)]); // Returns 0
  /// ```
  int _scoreThreeOfKind(List<Die> dice) {
    final counts = _getDiceCounts(dice);
    if (counts.values.any((count) => count >= 3)) {
      return dice.fold(0, (sum, die) => sum + die.value);
    }
    return 0;
  }

  /// Scores Four of a Kind: sum of all dice if 4+ match, else 0.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice.
  ///
  /// Returns:
  /// Sum of all dice if at least 4 dice show the same value, otherwise 0.
  ///
  /// Example:
  /// ```dart
  /// _scoreFourOfKind([Die(1), Die(3), Die(3), Die(3), Die(3)]); // Returns 13
  /// _scoreFourOfKind([Die(1), Die(2), Die(3), Die(4), Die(5)]); // Returns 0
  /// ```
  int _scoreFourOfKind(List<Die> dice) {
    final counts = _getDiceCounts(dice);
    if (counts.values.any((count) => count >= 4)) {
      return dice.fold(0, (sum, die) => sum + die.value);
    }
    return 0;
  }

  /// Scores Full House: 25 if exactly 3 of one + 2 of another, else 0.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice.
  ///
  /// Returns:
  /// 25 points if exactly 3 dice show one value and 2 dice show another.
  /// Returns 0 otherwise (4 of a kind + 1 does NOT count).
  ///
  /// Example:
  /// ```dart
  /// _scoreFullHouse([Die(2), Die(2), Die(2), Die(5), Die(5)]); // Returns 25
  /// _scoreFullHouse([Die(3), Die(3), Die(3), Die(3), Die(1)]); // Returns 0
  /// ```
  int _scoreFullHouse(List<Die> dice) {
    final counts = _getDiceCounts(dice);
    final values = counts.values.toList();
    // Must have exactly 2 different values: one with count 3, one with count 2
    if (values.contains(3) && values.contains(2)) {
      return 25;
    }
    return 0;
  }

  /// Scores Small Straight: 30 if 4 consecutive values, else 0.
  ///
  /// Valid small straights: [1,2,3,4], [2,3,4,5], [3,4,5,6]
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice.
  ///
  /// Returns:
  /// 30 points if 4 consecutive values are present, otherwise 0.
  ///
  /// Example:
  /// ```dart
  /// _scoreSmallStraight([Die(1), Die(2), Die(3), Die(4), Die(6)]); // Returns 30
  /// _scoreSmallStraight([Die(2), Die(3), Die(4), Die(5), Die(6)]); // Returns 30
  /// _scoreSmallStraight([Die(1), Die(3), Die(4), Die(5), Die(6)]); // Returns 0
  /// ```
  int _scoreSmallStraight(List<Die> dice) {
    final uniqueValues = dice.map((die) => die.value).toSet().toList()..sort();

    // Check for 4 consecutive values
    for (int i = 0; i <= uniqueValues.length - 4; i++) {
      final sequence = uniqueValues.sublist(i, i + 4);
      if (_isConsecutive(sequence)) {
        return 30;
      }
    }
    return 0;
  }

  /// Scores Large Straight: 40 if 5 consecutive values, else 0.
  ///
  /// Valid large straights: [1,2,3,4,5] or [2,3,4,5,6]
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice.
  ///
  /// Returns:
  /// 40 points if all 5 dice show consecutive values, otherwise 0.
  ///
  /// Example:
  /// ```dart
  /// _scoreLargeStraight([Die(1), Die(2), Die(3), Die(4), Die(5)]); // Returns 40
  /// _scoreLargeStraight([Die(6), Die(5), Die(4), Die(3), Die(2)]); // Returns 40
  /// _scoreLargeStraight([Die(1), Die(2), Die(3), Die(4), Die(6)]); // Returns 0
  /// ```
  int _scoreLargeStraight(List<Die> dice) {
    final uniqueValues = dice.map((die) => die.value).toSet().toList()..sort();

    // Must have exactly 5 unique values that are consecutive
    if (uniqueValues.length == 5 && _isConsecutive(uniqueValues)) {
      return 40;
    }
    return 0;
  }

  /// Scores Yatzy: 50 + (yatzyCount * 50) if all 5 dice match, else 0.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice.
  ///
  /// Returns:
  /// 50 points plus 50 for each previous Yatzy if all 5 dice match.
  /// Returns 0 otherwise.
  ///
  /// Example:
  /// ```dart
  /// _scoreYatzy([Die(3), Die(3), Die(3), Die(3), Die(3)]); // Returns 50
  /// _scoreYatzy([Die(6), Die(6), Die(6), Die(6), Die(6)]); // Returns 50 + (yatzyCount * 50)
  /// ```
  int _scoreYatzy(List<Die> dice) {
    final counts = _getDiceCounts(dice);
    if (counts.values.any((count) => count == 5)) {
      return 50 + (yatzyCount * 50);
    }
    return 0;
  }

  /// Scores Chance: sum of all dice.
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice.
  ///
  /// Returns:
  /// The sum of all dice values, regardless of combinations.
  ///
  /// Example:
  /// ```dart
  /// _scoreChance([Die(1), Die(2), Die(3), Die(4), Die(5)]); // Returns 15
  /// _scoreChance([Die(6), Die(6), Die(6), Die(6), Die(6)]); // Returns 30
  /// ```
  int _scoreChance(List<Die> dice) {
    return dice.fold(0, (sum, die) => sum + die.value);
  }

  /// Returns a map of die value to count.
  ///
  /// Parameters:
  /// - [dice]: The list of dice to count.
  ///
  /// Returns:
  /// A map where keys are die values (1-6) and values are their counts.
  ///
  /// Example:
  /// ```dart
  /// _getDiceCounts([Die(1), Die(2), Die(2), Die(3), Die(3)]);
  /// // Returns {1: 1, 2: 2, 3: 2}
  /// ```
  Map<int, int> _getDiceCounts(List<Die> dice) {
    final counts = <int, int>{};
    for (final die in dice) {
      counts[die.value] = (counts[die.value] ?? 0) + 1;
    }
    return counts;
  }

  /// Checks if a list of integers is consecutive.
  ///
  /// Parameters:
  /// - [values]: A sorted list of integers to check.
  ///
  /// Returns:
  /// True if each value is exactly 1 more than the previous.
  /// Returns true for lists with less than 2 elements.
  ///
  /// Example:
  /// ```dart
  /// _isConsecutive([1, 2, 3, 4]); // true
  /// _isConsecutive([2, 3, 4, 5]); // true
  /// _isConsecutive([1, 2, 4, 5]); // false
  /// ```
  bool _isConsecutive(List<int> values) {
    if (values.length < 2) return true;
    for (int i = 1; i < values.length; i++) {
      if (values[i] != values[i - 1] + 1) {
        return false;
      }
    }
    return true;
  }

  /// Returns the total score including upper bonus.
  ///
  /// Calculates the sum of upper section total, lower section total,
  /// and any applicable bonus.
  ///
  /// **Bonus Rule:** A bonus of 35 points is added if the upper section
  /// total is 63 or more.
  ///
  /// Returns:
  /// The grand total score including bonus.
  ///
  /// Example:
  /// ```dart
  /// sheet.getTotal(); // Returns upperTotal + lowerTotal + bonus
  /// ```
  int getTotal() {
    final upperTotal = getUpperTotal();
    final lowerTotal = getLowerTotal();
    return upperTotal + lowerTotal + getBonus();
  }

  /// Returns the sum of all upper section scores.
  ///
  /// The upper section includes Aces through Sixes.
  /// Only scored categories (non-null values) are included.
  ///
  /// Returns:
  /// The sum of all scored upper section categories.
  ///
  /// Example:
  /// ```dart
  /// sheet.getUpperTotal(); // Sum of Aces, Twos, Threes, Fours, Fives, Sixes
  /// ```
  int getUpperTotal() {
    return ScoreCategoryHelper.getUpperCategories()
        .where((category) => scores[category] != null)
        .fold(0, (sum, category) => sum + scores[category]!);
  }

  /// Returns the sum of all lower section scores.
  ///
  /// The lower section includes Three of a Kind through Chance.
  /// Only scored categories (non-null values) are included.
  ///
  /// Returns:
  /// The sum of all scored lower section categories.
  ///
  /// Example:
  /// ```dart
  /// sheet.getLowerTotal(); // Sum of all lower section categories
  /// ```
  int getLowerTotal() {
    return ScoreCategoryHelper.getLowerCategories()
        .where((category) => scores[category] != null)
        .fold(0, (sum, category) => sum + scores[category]!);
  }

  /// Returns the bonus score (35 if upper total >= 63, else 0).
  ///
  /// The bonus is awarded when the upper section total reaches 63 points
  /// or more, which requires scoring at least three of each die value (1-6).
  ///
  /// Returns:
  /// 35 if upper section total is 63 or more, otherwise 0.
  ///
  /// Example:
  /// ```dart
  /// sheet.getBonus(); // Returns 35 if upperTotal >= 63, else 0
  /// ```
  int getBonus() {
    return getUpperTotal() >= 63 ? 35 : 0;
  }

  /// Returns true if the [category] has been scored.
  ///
  /// Parameters:
  /// - [category]: The category to check.
  ///
  /// Returns:
  /// True if the category has a non-null score, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// sheet.isCategoryScored(ScoreCategory.aces); // true if scored
  /// ```
  bool isCategoryScored(ScoreCategory category) {
    return scores[category] != null;
  }

  /// Returns a list of categories that have not been scored yet.
  ///
  /// Returns:
  /// A list of [ScoreCategory] values where the score is null.
  ///
  /// Example:
  /// ```dart
  /// final empty = sheet.getEmptyCategories();
  /// print(empty.length); // Number of categories left to score
  /// ```
  List<ScoreCategory> getEmptyCategories() {
    return ScoreCategory.values
        .where((category) => !isCategoryScored(category))
        .toList();
  }

  /// Returns a new [ScoreSheet] instance with copied/updated values.
  ///
  /// Parameters:
  /// - [scores]: New score map to merge (optional).
  /// - [yatzyCount]: New Yatzy count (optional).
  ///
  /// Returns:
  /// A new [ScoreSheet] with the specified updates applied.
  ///
  /// Example:
  /// ```dart
  /// final updated = sheet.copyWith(yatzyCount: sheet.yatzyCount + 1);
  /// ```
  ScoreSheet copyWith({Map<ScoreCategory, int?>? scores, int? yatzyCount}) {
    final newScores = Map<ScoreCategory, int?>.from(this.scores);
    if (scores != null) {
      newScores.addAll(scores);
    }
    return ScoreSheet(yatzyCount: yatzyCount ?? this.yatzyCount)
      ..scores.addAll(newScores);
  }
}
