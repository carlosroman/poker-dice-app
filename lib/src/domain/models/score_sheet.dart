import 'score_category.dart';
import '../scoring/scorer.dart';

/// Represents a complete scorecard for a player in the poker dice game.
///
/// Tracks scores for all categories, tracks Yatzy occurrences, and
/// calculates totals and bonuses.
class ScoreSheet {
  /// Map of categories to their scores (null = not yet scored).
  final Map<ScoreCategory, int?> scores;

  /// Count of total Yatzy rolls (all 5 dice showing the same value).
  final int yatzyCount;

  /// Bonus points for achieving 63 or more in upper section.
  static const int bonusThreshold = 63;
  static const int bonusPoints = 35;

  /// Creates a new ScoreSheet.
  ///
  /// [scores] optional map of pre-filled scores.
  /// [yatzyCount] optional Yatzy count.
  const ScoreSheet({this.scores = const {}, this.yatzyCount = 0});

  /// Returns the list of minor section categories.
  static List<ScoreCategory> get minorCategories => [
    ScoreCategory.aces,
    ScoreCategory.twos,
    ScoreCategory.threes,
    ScoreCategory.fours,
    ScoreCategory.fives,
    ScoreCategory.sixes,
  ];

  /// Returns the list of major section categories.
  static List<ScoreCategory> get majorCategories => [
    ScoreCategory.threeOfKind,
    ScoreCategory.fourOfKind,
    ScoreCategory.fullHouse,
    ScoreCategory.smallStraight,
    ScoreCategory.largeStraight,
    ScoreCategory.yatzy,
    ScoreCategory.chance,
  ];

  /// Returns the list of all categories.
  static List<ScoreCategory> get allCategories => [
    ...minorCategories,
    ...majorCategories,
  ];

  /// Creates a new ScoreSheet with the score for [category] calculated and stored.
  ///
  /// [dice] is the list of 5 die values.
  /// Returns a new ScoreSheet instance (immutable).
  ScoreSheet score(ScoreCategory category, List<int> dice) {
    if (dice.length != 5) {
      throw ArgumentError('Dice must contain exactly 5 values');
    }

    final calculatedScore = _calculateCategoryScore(category, dice);
    final newScores = Map<ScoreCategory, int?>.of(scores);
    newScores[category] = calculatedScore;

    final newYatzyCount = category == ScoreCategory.yatzy && calculatedScore > 0
        ? yatzyCount + 1
        : yatzyCount;

    return ScoreSheet(scores: newScores, yatzyCount: newYatzyCount);
  }

  int _calculateCategoryScore(ScoreCategory category, List<int> dice) {
    if (category.isMinor) {
      return Scorer.calculateUpperScore(category, dice);
    }
    if (category == ScoreCategory.yatzy) {
      return Scorer.scoreYatzy(dice, yatzyCount: yatzyCount);
    }
    return Scorer.calculateLowerScore(category, dice);
  }

  /// Returns the total score including bonus.
  int getTotal() {
    return getMinorTotal() + getMajorTotal() + getBonus();
  }

  /// Returns the sum of all minor section scores (excluding bonus).
  ///
  /// Returns 0 for categories that haven't been scored yet.
  int getMinorTotal() {
    return minorCategories.fold(0, (sum, category) {
      final score = scores[category] ?? 0;
      return sum + score;
    });
  }

  /// Returns the sum of all major section scores.
  ///
  /// Returns 0 for categories that haven't been scored yet.
  int getMajorTotal() {
    return majorCategories.fold(0, (sum, category) {
      final score = scores[category] ?? 0;
      return sum + score;
    });
  }

  /// Returns the bonus points if minor section total is 63 or more.
  ///
  /// Returns 35 if minor section >= 63, otherwise 0.
  int getBonus() {
    return getMinorTotal() >= bonusThreshold ? bonusPoints : 0;
  }

  /// Returns true if [category] has been scored.
  bool isCategoryScored(ScoreCategory category) {
    return scores.containsKey(category) && scores[category] != null;
  }

  /// Returns a list of categories that haven't been scored yet.
  List<ScoreCategory> getEmptyCategories() {
    return allCategories
        .where((category) => !isCategoryScored(category))
        .toList();
  }

  /// Creates a copy of this ScoreSheet with optional new values.
  ///
  /// This is used for immutability when modifying the score sheet.
  ScoreSheet copyWith({Map<ScoreCategory, int?>? scores, int? yatzyCount}) {
    return ScoreSheet(
      scores: scores ?? Map<ScoreCategory, int?>.of(this.scores),
      yatzyCount: yatzyCount ?? this.yatzyCount,
    );
  }

  /// Returns true if all categories have been scored.
  bool get isComplete {
    return getEmptyCategories().isEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScoreSheet) return false;

    final scoresEqual =
        scores.length == other.scores.length &&
        scores.entries.every((entry) => other.scores[entry.key] == entry.value);

    return scoresEqual && yatzyCount == other.yatzyCount;
  }

  @override
  int get hashCode {
    // Create a deterministic hash by sorting keys first
    final sortedEntries = scores.entries.toList()
      ..sort((a, b) => a.key.index.compareTo(b.key.index));
    final scoresHash = sortedEntries.fold(0, (hash, entry) {
      return Object.hash(hash, entry.key.index, entry.value);
    });
    return Object.hash(scoresHash, yatzyCount);
  }

  @override
  String toString() {
    return 'ScoreSheet(scores: $scores, yatzyCount: $yatzyCount)';
  }
}
