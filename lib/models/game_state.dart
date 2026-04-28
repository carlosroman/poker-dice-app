import 'category.dart';
import 'dice_roll.dart';

/// Represents the complete state of a Poker Dice game.
///
/// Manages dice rolls, scores, turns, and game progression.
class GameState {
  /// Maximum number of rolls allowed per turn.
  static const int maxRollsPerTurn = 3;

  /// Target score for upper section to qualify for bonus.
  static const int upperSectionTarget = 63;

  /// Bonus points awarded for scoring 63+ in upper section.
  static const int bonusPoints = 35;

  /// Current dice roll (null at start of turn).
  final DiceRoll? diceRoll;

  /// Map of scored categories and their scores.
  final Map<Category, int> scores;

  /// Currently selected category for scoring.
  final Category? selectedCategory;

  /// Number of rolls remaining in current turn.
  final int remainingRolls;

  /// Current turn number (starts at 1).
  final int currentTurn;

  /// Whether the game is over (all categories scored).
  final bool isGameOver;

  /// Total of upper section scores (before bonus).
  final int upperSectionTotal;

  /// Whether bonus (+35) was awarded.
  final bool bonusAwarded;

  /// Final calculated score including bonus.
  final int totalScore;

  /// Whether the game has been started (user tapped NEW GAME).
  final bool isGameStarted;

  GameState({
    this.diceRoll,
    Map<Category, int>? scores,
    this.selectedCategory,
    this.remainingRolls = maxRollsPerTurn,
    this.currentTurn = 1,
    this.isGameOver = false,
    this.upperSectionTotal = 0,
    this.bonusAwarded = false,
    this.totalScore = 0,
    this.isGameStarted = false,
  }) : scores = scores ?? {};

  /// Starts a new turn, rolls dice, resets rolls to 3.
  GameState startTurn() {
    if (isGameOver) return this;

    final newDiceRoll = DiceRoll.random();
    return GameState(
      diceRoll: newDiceRoll,
      scores: Map.from(scores),
      selectedCategory: null,
      remainingRolls: maxRollsPerTurn,
      currentTurn: currentTurn,
      isGameOver: false,
      upperSectionTotal: upperSectionTotal,
      bonusAwarded: bonusAwarded,
      totalScore: totalScore,
    );
  }

  /// Toggles held state of a die at the given index.
  GameState toggleDieHeld(int index) {
    if (diceRoll == null || index < 0 || index >= diceRoll!.dice.length) {
      return this;
    }

    final newDiceRoll = diceRoll!.toggleDieHeld(index);

    return GameState(
      diceRoll: newDiceRoll,
      scores: Map.from(scores),
      selectedCategory: selectedCategory,
      remainingRolls: remainingRolls,
      currentTurn: currentTurn,
      isGameOver: isGameOver,
      upperSectionTotal: upperSectionTotal,
      bonusAwarded: bonusAwarded,
      totalScore: totalScore,
    );
  }

  /// Rolls unheld dice, decrements remainingRolls.
  GameState rollDice() {
    if (diceRoll == null || remainingRolls <= 0) return this;

    final newDiceRoll = diceRoll!.rollUnheldDice();
    return GameState(
      diceRoll: newDiceRoll,
      scores: Map.from(scores),
      selectedCategory: selectedCategory,
      remainingRolls: remainingRolls - 1,
      currentTurn: currentTurn,
      isGameOver: isGameOver,
      upperSectionTotal: upperSectionTotal,
      bonusAwarded: bonusAwarded,
      totalScore: totalScore,
    );
  }

  /// Selects a category for scoring.
  GameState selectCategory(Category category) {
    if (scores.containsKey(category)) return this;

    return GameState(
      diceRoll: diceRoll,
      scores: Map.from(scores),
      selectedCategory: category,
      remainingRolls: remainingRolls,
      currentTurn: currentTurn,
      isGameOver: isGameOver,
      upperSectionTotal: upperSectionTotal,
      bonusAwarded: bonusAwarded,
      totalScore: totalScore,
    );
  }

  /// Records a score for the given category.
  GameState scoreCategory(Category category, int score) {
    if (scores.containsKey(category)) return this;

    final newScores = Map<Category, int>.from(scores);
    newScores[category] = score;

    final newUpperSectionTotal = calculateUpperSectionTotalWithScores(
      newScores,
    );
    final newBonusAwarded = newUpperSectionTotal >= upperSectionTarget;
    final newTotalScore = calculateTotalScoreWithScores(
      newScores,
      newBonusAwarded,
    );
    final remainingCategories = getRemainingCategoriesWithScores(newScores);
    final newIsGameOver = remainingCategories.isEmpty;

    return GameState(
      diceRoll: null,
      scores: newScores,
      selectedCategory: null,
      remainingRolls: maxRollsPerTurn,
      currentTurn: newIsGameOver ? currentTurn : currentTurn + 1,
      isGameOver: newIsGameOver,
      upperSectionTotal: newUpperSectionTotal,
      bonusAwarded: newBonusAwarded,
      totalScore: newTotalScore,
    );
  }

  /// Sums upper section scores.
  int calculateUpperSectionTotal() =>
      calculateUpperSectionTotalWithScores(scores);

  int calculateUpperSectionTotalWithScores(Map<Category, int> currentScores) {
    return Category.values
        .where((cat) => cat.index < 6) // Upper section: 1-6
        .fold(0, (sum, cat) => sum + (currentScores[cat] ?? 0));
  }

  /// Returns 35 if upper >= 63, else 0.
  int calculateBonus() => calculateBonusWithScores(scores);

  int calculateBonusWithScores(Map<Category, int> currentScores) {
    final upperTotal = calculateUpperSectionTotalWithScores(currentScores);
    return upperTotal >= upperSectionTarget ? bonusPoints : 0;
  }

  /// Calculates total including bonus and lower section.
  int calculateTotalScore() =>
      calculateTotalScoreWithScores(scores, bonusAwarded);

  int calculateTotalScoreWithScores(
    Map<Category, int> currentScores,
    bool currentBonusAwarded,
  ) {
    final allScoresSum = currentScores.values.fold(
      0,
      (sum, score) => sum + score,
    );
    final bonus = currentBonusAwarded ? bonusPoints : 0;
    return allScoresSum + bonus;
  }

  /// Returns categories not yet scored.
  List<Category> getRemainingCategories() =>
      getRemainingCategoriesWithScores(scores);

  List<Category> getRemainingCategoriesWithScores(
    Map<Category, int> currentScores,
  ) {
    return Category.values
        .where((cat) => !currentScores.containsKey(cat))
        .toList();
  }

  /// Checks if category can be scored.
  bool canScoreCategory(Category category) {
    return !scores.containsKey(category) && diceRoll != null;
  }

  /// Creates a copy with the given fields replaced.
  GameState copyWith({
    DiceRoll? diceRoll,
    Map<Category, int>? scores,
    Category? selectedCategory,
    int? remainingRolls,
    int? currentTurn,
    bool? isGameOver,
    int? upperSectionTotal,
    bool? bonusAwarded,
    int? totalScore,
  }) {
    return GameState(
      diceRoll: diceRoll ?? this.diceRoll,
      scores: scores ?? Map.from(this.scores),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      remainingRolls: remainingRolls ?? this.remainingRolls,
      currentTurn: currentTurn ?? this.currentTurn,
      isGameOver: isGameOver ?? this.isGameOver,
      upperSectionTotal: upperSectionTotal ?? this.upperSectionTotal,
      bonusAwarded: bonusAwarded ?? this.bonusAwarded,
      totalScore: totalScore ?? this.totalScore,
    );
  }

  /// Copies all fields from another GameState.
  ///
  /// Used for restoring saved game state.
  GameState copyFrom(GameState other) {
    return GameState(
      diceRoll: other.diceRoll,
      scores: Map.from(other.scores),
      selectedCategory: other.selectedCategory,
      remainingRolls: other.remainingRolls,
      currentTurn: other.currentTurn,
      isGameOver: other.isGameOver,
      upperSectionTotal: other.upperSectionTotal,
      bonusAwarded: other.bonusAwarded,
      totalScore: other.totalScore,
    );
  }

  /// Whether dice have been rolled in the current turn.
  ///
  /// Returns true if diceRoll is not null, false otherwise.
  bool get hasRolled => diceRoll != null;
}
