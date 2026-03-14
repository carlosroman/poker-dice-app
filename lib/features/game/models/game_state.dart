import '../../../core/constants/dice_faces.dart';
import 'dice.dart';

/// Represents the complete state of a Poker Dice game.
///
/// This immutable data class manages all game state including dice,
/// rolls remaining, scoring categories, and game progress.
class GameState {
  /// Collection of 5 dice used in the game.
  final List<Dice> dice;

  /// Counter for remaining rolls in current turn (starts at 3).
  final int rollsRemaining;

  /// Whether a turn is currently active.
  final bool isTurnActive;

  /// List of 13 scoring categories with scored/unscored status.
  final List<ScoreCategory> scoreCategories;

  /// Current turn number (starts at 1).
  final int turnNumber;

  /// Whether the game has ended.
  final bool isGameOver;

  /// Index of the category currently selected but not yet confirmed (null if none).
  final int? pendingSelection;

  /// Creates a new GameState instance.
  ///
  /// [dice] defaults to 5 fresh dice.
  /// [rollsRemaining] defaults to [MAX_ROLLS].
  /// [isTurnActive] defaults to true.
  /// [scoreCategories] defaults to 13 unscored categories.
  /// [turnNumber] defaults to 1.
  /// [isGameOver] defaults to false.
  /// [pendingSelection] defaults to null (no pending selection).
  GameState({
    List<Dice>? dice,
    this.rollsRemaining = MAX_ROLLS,
    this.isTurnActive = true,
    List<ScoreCategory>? scoreCategories,
    this.turnNumber = 1,
    this.isGameOver = false,
    this.pendingSelection,
  }) : dice = dice ?? List.generate(NUM_DICE, (_) => Dice()),
       scoreCategories =
           scoreCategories ??
           List.generate(
             NUM_CATEGORIES,
             (index) => ScoreCategory(index: index),
           );

  /// Returns a new [GameState] with fresh state for a new game.
  GameState resetGame() {
    return GameState(
      dice: List.generate(NUM_DICE, (_) => Dice()),
      rollsRemaining: MAX_ROLLS,
      isTurnActive: true,
      scoreCategories: List.generate(
        NUM_CATEGORIES,
        (index) => ScoreCategory(index: index),
      ),
      turnNumber: 1,
      isGameOver: false,
      pendingSelection: null,
    );
  }

  /// Returns a new [GameState] with dice reset, rolls=3, turn active.
  GameState resetTurn() {
    return GameState(
      dice: List.generate(NUM_DICE, (_) => Dice()),
      rollsRemaining: MAX_ROLLS,
      isTurnActive: true,
      scoreCategories: scoreCategories,
      turnNumber: turnNumber,
      isGameOver: isGameOver,
      pendingSelection: null,
    );
  }

  /// Returns a new [GameState] with the pending selection set.
  ///
  /// [index] is the category index to set as pending, or null to clear.
  GameState selectPending(int? index) {
    return GameState(
      dice: dice,
      rollsRemaining: rollsRemaining,
      isTurnActive: isTurnActive,
      scoreCategories: scoreCategories,
      turnNumber: turnNumber,
      isGameOver: isGameOver,
      pendingSelection: index,
    );
  }

  /// Returns the pending selection index, or null if none.
  int? getPendingSelection() {
    return pendingSelection;
  }

  /// Serializes this [GameState] to a JSON map.
  ///
  /// Returns a map containing all game state properties.
  Map<String, dynamic> toJson() {
    return {
      'dice': dice.map((d) => d.toJson()).toList(),
      'rollsRemaining': rollsRemaining,
      'isTurnActive': isTurnActive,
      'scoreCategories': scoreCategories.map((c) => c.toJson()).toList(),
      'turnNumber': turnNumber,
      'isGameOver': isGameOver,
      'pendingSelection': pendingSelection,
    };
  }

  /// Creates a [GameState] instance from a JSON map.
  ///
  /// [json] should contain all game state properties.
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      dice:
          (json['dice'] as List<dynamic>?)
              ?.map((d) => Dice.fromJson(d as Map<String, dynamic>))
              .toList() ??
          List.generate(NUM_DICE, (_) => Dice()),
      rollsRemaining: (json['rollsRemaining'] as int?) ?? MAX_ROLLS,
      isTurnActive: (json['isTurnActive'] as bool?) ?? true,
      scoreCategories:
          (json['scoreCategories'] as List<dynamic>?)
              ?.map((c) => ScoreCategory.fromJson(c as Map<String, dynamic>))
              .toList() ??
          List.generate(NUM_CATEGORIES, (index) => ScoreCategory(index: index)),
      turnNumber: (json['turnNumber'] as int?) ?? 1,
      isGameOver: (json['isGameOver'] as bool?) ?? false,
      pendingSelection: json['pendingSelection'] as int?,
    );
  }

  /// Returns a new [GameState] with the pending selection cleared.
  GameState clearPendingSelection() {
    return GameState(
      dice: dice,
      rollsRemaining: rollsRemaining,
      isTurnActive: isTurnActive,
      scoreCategories: scoreCategories,
      turnNumber: turnNumber,
      isGameOver: isGameOver,
      pendingSelection: null,
    );
  }

  /// Returns a new [GameState] with the specified category marked as scored.
  ///
  /// [index] is the category index (0-12).
  /// [score] is the score to assign to the category.
  GameState fillCategory(int index, int score) {
    final updatedCategories = List<ScoreCategory>.from(scoreCategories);
    updatedCategories[index] = ScoreCategory(index: index, score: score);
    return GameState(
      dice: dice,
      rollsRemaining: rollsRemaining,
      isTurnActive: isTurnActive,
      scoreCategories: updatedCategories,
      turnNumber: turnNumber,
      isGameOver: isGameOver,
      pendingSelection: null,
    );
  }

  /// Checks if the category at [index] has been scored.
  bool isCategoryScored(int index) {
    return scoreCategories[index].score != null;
  }

  /// Returns the number of rolls remaining.
  int getRemainingRolls() {
    return rollsRemaining;
  }

  /// Calculates the upper section total score.
  ///
  /// Upper section consists of categories 0-5 (pairs of each face).
  int getUpperSectionTotal() {
    int total = 0;
    for (int i = 0; i < 6; i++) {
      if (isCategoryScored(i)) {
        total += scoreCategories[i].score!;
      }
    }
    return total;
  }

  /// Calculates the bonus score.
  ///
  /// Returns 20 points if upper section total is >= BONUS_THRESHOLD, otherwise 0.
  int getBonus() {
    return getUpperSectionTotal() >= BONUS_THRESHOLD ? BONUS_POINTS : 0;
  }

  /// Calculates the total score including all categories and bonus.
  int getTotalScore() {
    int total = 0;
    for (int i = 0; i < NUM_CATEGORIES; i++) {
      if (isCategoryScored(i)) {
        total += scoreCategories[i].score!;
      }
    }
    total += getBonus();
    return total;
  }

  /// Returns the count of unscored categories.
  int categoriesRemaining() {
    int count = 0;
    for (int i = 0; i < NUM_CATEGORIES; i++) {
      if (!isCategoryScored(i)) {
        count++;
      }
    }
    return count;
  }
}

/// Represents a single scoring category in the game.
///
/// This immutable data class tracks the name and score status
/// of each of the 13 scoring categories.
class ScoreCategory {
  /// The scored value, or null if not yet scored.
  final int? score;

  /// The category index (0-12).
  final int categoryIndex;

  /// Creates a new ScoreCategory instance.
  ///
  /// [index] is required and sets the category index.
  /// [score] defaults to null (unscored).
  ScoreCategory({required int index, this.score})
    : categoryIndex = index,
      name = _getCategoryName(index);

  /// The display name of the category.
  final String name;

  /// Returns the category name based on the index.
  static String _getCategoryName(int index) {
    if (index < 6) {
      return UPPER_CATEGORIES[index];
    } else if (index < 12) {
      return LOWER_CATEGORIES[index - 6];
    } else {
      return BONUS_CATEGORY;
    }
  }

  /// Creates a copy of this [ScoreCategory] with the given fields replaced.
  ScoreCategory copyWith({int? index, int? score}) {
    return ScoreCategory(
      index: index ?? categoryIndex,
      score: score ?? this.score,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScoreCategory &&
        other.name == name &&
        other.score == score &&
        other.categoryIndex == categoryIndex;
  }

  @override
  int get hashCode => name.hashCode ^ score.hashCode ^ categoryIndex.hashCode;

  @override
  String toString() =>
      'ScoreCategory(name: $name, score: $score, categoryIndex: $categoryIndex)';

  /// Serializes this [ScoreCategory] to a JSON map.
  ///
  /// Returns a map with 'categoryIndex', 'score', and 'name' keys.
  Map<String, dynamic> toJson() {
    return {'categoryIndex': categoryIndex, 'score': score, 'name': name};
  }

  /// Creates a [ScoreCategory] instance from a JSON map.
  ///
  /// [json] should contain 'categoryIndex' (int), 'score' (int?), and 'name' (String) keys.
  factory ScoreCategory.fromJson(Map<String, dynamic> json) {
    return ScoreCategory(
      index: json['categoryIndex'] as int,
      score: json['score'] as int?,
    );
  }
}
