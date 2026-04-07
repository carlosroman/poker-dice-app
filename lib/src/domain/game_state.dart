import '../domain/models/die.dart';
import '../domain/models/game_round.dart';
import '../domain/models/score_category.dart';
import '../domain/models/score_sheet.dart';

/// Represents the complete state of a Poker Dice game.
///
/// This class manages the entire game flow including:
/// - Current round state (5 dice and roll count)
/// - Score sheet with all 13 category scores
/// - Game over status (when all categories are scored)
///
/// **Game Flow:**
/// 1. Game starts in [GameInitial] state
/// 2. First roll transitions to [GamePlaying] state
/// 3. Player rolls up to 3 times per round, holding desired dice
/// 4. Player selects a category to score
/// 5. New round starts automatically
/// 6. Game ends when all 13 categories are scored ([GameOver] state)
///
/// **Immutability:**
/// All state-modifying methods return new instances to maintain
/// immutable state, which is essential for reactive state management.
///
/// Example:
/// ```dart
/// var state = GameState(); // Initial state
/// state = state.rollDice(); // First roll
/// state = state.toggleDie(0); // Hold first die
/// state = state.selectCategory(ScoreCategory.aces); // Score and new round
/// ```
class GameState {
  /// The current round of play.
  ///
  /// Contains the 5 dice and the number of rolls performed (0-3).
  final GameRound currentRound;

  /// The score sheet tracking all 13 category scores.
  ///
  /// Contains scores for all categories (null = not yet scored)
  /// and tracks the Yatzy count for bonus calculation.
  final ScoreSheet scoreSheet;

  /// Whether the game has ended (all 13 categories scored).
  ///
  /// When true, no more game actions can be performed except
  /// starting a new game.
  final bool isGameOver;

  /// Creates a new [GameState] with initial round and score sheet.
  ///
  /// Parameters:
  /// - [currentRound]: Optional initial round. Defaults to new GameRound with 5 dice.
  /// - [scoreSheet]: Optional initial score sheet. Defaults to new ScoreSheet with no scores.
  /// - [isGameOver]: Whether the game is over. Defaults to false.
  ///
  /// Example:
  /// ```dart
  /// final state = GameState(); // Fresh game
  /// final state2 = GameState(isGameOver: true); // Game over state
  /// ```
  GameState({
    GameRound? currentRound,
    ScoreSheet? scoreSheet,
    this.isGameOver = false,
  }) : currentRound = currentRound ?? GameRound(),
       scoreSheet = scoreSheet ?? ScoreSheet();

  /// Rolls the unheld dice in the current round.
  ///
  /// Rolls all dice that are not held, generating new random values.
  /// Held dice retain their current values.
  ///
  /// Returns:
  /// A new [GameState] instance with the updated round (incremented rollCount).
  /// Returns the same instance if no more rolls are available (rollCount >= 3).
  ///
  /// Example:
  /// ```dart
  /// var state = GameState();
  /// state = state.rollDice(); // First roll
  /// state = state.toggleDie(0); // Hold first die
  /// state = state.rollDice(); // Second roll (only dice 1-4 rolled)
  /// ```
  GameState rollDice() {
    if (!currentRound.canRoll()) {
      return this;
    }

    final updatedRound = currentRound.rollDice();
    return GameState(
      currentRound: updatedRound,
      scoreSheet: scoreSheet,
      isGameOver: isGameOver,
    );
  }

  /// Toggles the held state of the die at the given [index].
  ///
  /// Holding a die prevents it from being rolled in subsequent rolls.
  /// Players typically hold dice that contribute to desired combinations.
  ///
  /// Parameters:
  /// - [index]: The index of the die to toggle (0-4).
  ///
  /// Returns:
  /// A new [GameState] instance with the updated round.
  ///
  /// Throws:
  /// - [ArgumentError]: If [index] is out of bounds (< 0 or >= 5).
  ///
  /// Example:
  /// ```dart
  /// var state = GameState();
  /// state = state.toggleDie(0); // Hold die at index 0
  /// state = state.toggleDie(0); // Unhold die at index 0
  /// ```
  GameState toggleDie(int index) {
    final updatedRound = currentRound.toggleDie(index);
    return GameState(
      currentRound: updatedRound,
      scoreSheet: scoreSheet,
      isGameOver: isGameOver,
    );
  }

  /// Scores a [category] and starts a new round.
  ///
  /// This method scores the selected category using the current dice values,
  /// updates the score sheet, and automatically starts a new round with
  /// fresh dice. If all categories are scored, the game ends.
  ///
  /// Parameters:
  /// - [category]: The category to score. Must be an unscored category.
  ///
  /// Returns:
  /// A new [GameState] instance with:
  /// - Updated score sheet with the new score
  /// - New round with 5 fresh dice and rollCount=0 (if game not over)
  /// - [isGameOver] set to true if all categories are now scored
  ///
  /// Throws:
  /// - [StateError]: If the category is already scored.
  /// - [ArgumentError]: If the category is invalid.
  ///
  /// Example:
  /// ```dart
  /// var state = GameState();
  /// state = state.rollDice(); // Roll dice
  /// state = state.selectCategory(ScoreCategory.aces); // Score aces, new round
  /// ```
  GameState selectCategory(ScoreCategory category) {
    // Validate that the category is not already scored
    if (scoreSheet.isCategoryScored(category)) {
      throw StateError(
        'Cannot score category ${category.displayName}: already scored.',
      );
    }

    // Create new score sheet with copied scores
    final newScoreSheet = ScoreSheet(yatzyCount: scoreSheet.yatzyCount)
      ..scores.addAll(scoreSheet.scores);

    // Calculate the score (this uses the current yatzyCount for Yatzy scoring)
    newScoreSheet.score(category, currentRound.dice);

    // Increment yatzyCount if we just scored a Yatzy
    final updatedYatzyCount =
        category == ScoreCategory.yatzy && _isYatzy(currentRound.dice)
        ? newScoreSheet.yatzyCount + 1
        : newScoreSheet.yatzyCount;

    // Create final score sheet with updated yatzyCount
    final finalScoreSheet = ScoreSheet(yatzyCount: updatedYatzyCount)
      ..scores.addAll(newScoreSheet.scores);

    // Check if game is over after scoring
    final remainingCategories = finalScoreSheet.getEmptyCategories();
    final gameEnded = remainingCategories.isEmpty;

    // Start a new round if game is not over
    if (!gameEnded) {
      return GameState(
        currentRound: GameRound(),
        scoreSheet: finalScoreSheet,
        isGameOver: false,
      );
    }

    // Game is over, return final state
    return GameState(
      currentRound: currentRound,
      scoreSheet: finalScoreSheet,
      isGameOver: true,
    );
  }

  /// Resets the game to initial state.
  ///
  /// Creates a brand new game with fresh dice and empty score sheet.
  /// This is typically called when the player wants to start a new game.
  ///
  /// Returns:
  /// A new [GameState] instance with:
  /// - New [GameRound] with 5 fresh dice
  /// - New [ScoreSheet] with no scores
  /// - [isGameOver] set to false
  ///
  /// Example:
  /// ```dart
  /// var state = GameState();
  /// // ... play game ...
  /// state = state.newGame(); // Start fresh game
  /// ```
  GameState newGame() {
    return GameState(
      currentRound: GameRound(),
      scoreSheet: ScoreSheet(),
      isGameOver: false,
    );
  }

  /// Returns a list of categories that can currently be scored.
  ///
  /// During normal play, returns only unscored (empty) categories.
  /// When the game is over, returns all 13 categories for display purposes.
  ///
  /// Returns:
  /// A list of [ScoreCategory] values that can be selected for scoring.
  ///
  /// Example:
  /// ```dart
  /// final valid = state.getValidCategories();
  /// print(valid.length); // Number of categories left to score
  /// ```
  List<ScoreCategory> getValidCategories() {
    if (isGameOver) {
      return ScoreCategory.values;
    }
    return scoreSheet.getEmptyCategories();
  }

  /// Returns the number of rolls remaining in the current round.
  ///
  /// Players get up to 3 rolls per round. This method calculates
  /// how many rolls are left based on the current roll count.
  ///
  /// Returns:
  /// An integer between 0 and 3 (inclusive) indicating remaining rolls.
  ///
  /// Example:
  /// ```dart
  /// state.getRemainingRolls(); // 3 on first turn, 2 after first roll, etc.
  /// ```
  int getRemainingRolls() {
    return 3 - currentRound.rollCount;
  }

  /// Creates a copy of this [GameState] with optional updated values.
  ///
  /// Parameters:
  /// - [currentRound]: New round (defaults to current round if null).
  /// - [scoreSheet]: New score sheet (defaults to current sheet if null).
  /// - [isGameOver]: New game over status (defaults to current if null).
  ///
  /// Returns:
  /// A new [GameState] instance with the specified properties updated.
  ///
  /// Example:
  /// ```dart
  /// final copy = state.copyWith(isGameOver: true);
  /// ```
  GameState copyWith({
    GameRound? currentRound,
    ScoreSheet? scoreSheet,
    bool? isGameOver,
  }) {
    return GameState(
      currentRound: currentRound ?? this.currentRound,
      scoreSheet: scoreSheet ?? this.scoreSheet,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }

  /// Checks if the [dice] form a Yatzy (all 5 dice show the same value).
  ///
  /// Parameters:
  /// - [dice]: The list of 5 dice to check.
  ///
  /// Returns:
  /// True if all dice show the same value, false otherwise.
  /// Returns false for empty dice lists.
  ///
  /// Example:
  /// ```dart
  /// _isYatzy([Die(3), Die(3), Die(3), Die(3), Die(3)]); // true
  /// _isYatzy([Die(1), Die(2), Die(3), Die(4), Die(5)]); // false
  /// ```
  bool _isYatzy(List<Die> dice) {
    if (dice.isEmpty) return false;
    final firstValue = dice.first.value;
    return dice.every((die) => die.value == firstValue);
  }
}
