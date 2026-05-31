/// Represents the current state of a poker dice game.
///
/// This immutable model tracks all game state including player scores,
/// dice rolls, and game progress.
import 'package:poker_dice/models/category.dart';

class GameState {
  /// Creates a new game state.
  const GameState({
    this.scores = const {},
    this.diceRoll,
    this.isRolling = false,
    this.selectedCategory,
    this.currentRollsRemaining = 3,
  });

  /// Default empty game state.
  static const initial = GameState();

  /// Scores for each category.
  final Map<String, int> scores;

  /// The current dice roll values.
  final List<int>? diceRoll;

  /// Whether dice are currently rolling (for animation).
  final bool isRolling;

  /// The currently selected category for scoring.
  final String? selectedCategory;

  /// Number of rolls remaining in the current turn.
  final int currentRollsRemaining;

  /// Whether the game is over (computed from scored categories).
  bool get isGameOver => scores.length >= Category.values.length;

  /// Calculates the upper section total.
  int get upperSectionTotal {
    const upperCategories = ['ones', 'twos', 'threes', 'fours', 'fives', 'sixes'];
    return upperCategories.fold(0, (sum, category) {
      return sum + (scores[category] ?? 0);
    });
  }

  /// Calculates the bonus award (50 points if upper total >= 63).
  int get bonusAwarded {
    return upperSectionTotal >= 63 ? 50 : 0;
  }

  /// Calculates the total score including all categories and bonus.
  int get totalScore {
    return scores.values.fold(0, (sum, score) => sum + score) + bonusAwarded;
  }

  /// Creates a copy of this state with the given fields replaced.
  ///
  /// Passing `null` for a parameter keeps the current value.
  /// To explicitly reset a nullable field to null, use the
  /// [GameState] constructor directly.
  GameState copyWith({
    Map<String, int>? scores,
    List<int>? diceRoll,
    bool? isRolling,
    String? selectedCategory,
    int? currentRollsRemaining,
  }) {
    return GameState(
      scores: scores ?? this.scores,
      diceRoll: diceRoll ?? this.diceRoll,
      isRolling: isRolling ?? this.isRolling,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentRollsRemaining: currentRollsRemaining ?? this.currentRollsRemaining,
    );
  }

  /// Creates a new state with a dice roll.
  GameState rollDice(List<int> dice) {
    return copyWith(diceRoll: dice, isRolling: true);
  }

  /// Resets the current turn state.
  GameState resetTurn() {
    return GameState(
      scores: scores,
      diceRoll: null,
      isRolling: false,
      selectedCategory: null,
      currentRollsRemaining: 3,
    );
  }

  /// Adds a score for a category.
  ///
  /// Ignores the score if the category has already been scored.
  GameState addScore(String category, int score) {
    if (scores.containsKey(category)) return this;
    final newScores = Map<String, int>.from(scores);
    newScores[category] = score;
    return GameState(
      scores: newScores,
      diceRoll: diceRoll,
      isRolling: isRolling,
      selectedCategory: null,
      currentRollsRemaining: 3,
    );
  }

  /// Selects a category for scoring.
  ///
  /// Pass `null` to deselect the current category.
  GameState selectCategory(String? category) {
    if (category == null) {
      return GameState(
        scores: scores,
        diceRoll: diceRoll,
        isRolling: isRolling,
        selectedCategory: null,
        currentRollsRemaining: currentRollsRemaining,
      );
    }
    return copyWith(selectedCategory: category);
  }

  /// Decrements the remaining rolls.
  GameState decrementRolls() {
    return copyWith(currentRollsRemaining: currentRollsRemaining - 1);
  }

  /// Marks the game as ended.
  ///
  /// Since [isGameOver] is now computed from [scores], this returns
  /// the current state unchanged. The game is over when all categories
  /// have been scored.
  GameState endGame() {
    return this;
  }

  /// Resets the game to initial state.
  GameState reset() {
    return const GameState();
  }
}
