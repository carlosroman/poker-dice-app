import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/die.dart';
import 'package:poker_dice/models/dice_roll.dart';

/// Const sentinel to distinguish "not provided" from "explicitly null" in copyWith.
class _NotProvided {
  const _NotProvided();
}

/// Tracks the full state of a poker dice game.
class GameState {
  static const int _maxRolls = 3;
  static const int _bonusThreshold = 63;

  final int currentRollsRemaining;
  final DiceRoll? currentDiceRoll;
  final Category? selectedCategory;
  final Map<Category, int?> scores;

  /// Sum of scored upper section categories.
  int get upperSectionTotal {
    return Category.getUpperCategories().fold(
      0,
      (sum, cat) => sum + (scores[cat] ?? 0),
    );
  }

  /// True when upper section total meets or exceeds the bonus threshold.
  bool get bonusAwarded => upperSectionTotal >= _bonusThreshold;

  /// Sum of all scored categories plus any bonus.
  int get totalScore {
    final scoresSum = scores.values.fold(0, (sum, score) => sum + (score ?? 0));
    return scoresSum + (bonusAwarded ? 35 : 0);
  }

  /// True when all categories have been scored.
  bool get isGameOver => scores.values.every((score) => score != null);

  GameState({
    this.currentRollsRemaining = _maxRolls,
    this.currentDiceRoll,
    this.selectedCategory,
    Map<Category, int?>? scores,
  }) : scores = scores ?? {for (final cat in Category.values) cat: null};

  /// Returns a new [GameState] with the specified fields replaced.
  /// Use null to explicitly clear a nullable field.
  GameState copyWith({
    Object? currentRollsRemaining = const _NotProvided(),
    Object? currentDiceRoll = const _NotProvided(),
    Object? selectedCategory = const _NotProvided(),
    Map<Category, int?>? scores,
  }) {
    return GameState(
      currentRollsRemaining: currentRollsRemaining is! _NotProvided
          ? currentRollsRemaining as int
          : this.currentRollsRemaining,
      currentDiceRoll: currentDiceRoll is! _NotProvided
          ? currentDiceRoll as DiceRoll?
          : this.currentDiceRoll,
      selectedCategory: selectedCategory is! _NotProvided
          ? selectedCategory as Category?
          : this.selectedCategory,
      scores: scores ?? this.scores,
    );
  }

  /// Returns a fresh [GameState] for a new game.
  GameState reset() {
    return GameState();
  }

  /// Records a [score] for the given [category].
  /// Returns a new [GameState] with the updated scores.
  GameState addScore(Category category, int score) {
    final newScores = Map<Category, int?>.from(scores);
    newScores[category] = score;
    return copyWith(scores: newScores);
  }

  /// Highlights or clears the [category] for selection.
  GameState selectCategory(Category? category) {
    return copyWith(
      selectedCategory: category,
      currentRollsRemaining: category != null ? 0 : currentRollsRemaining,
    );
  }

  /// Rolls the dice, re-rolling unheld dice if possible.
  /// Returns a new [GameState] with the updated roll.
  GameState rollDice() {
    if (currentRollsRemaining <= 0) return this;

    final newRoll = currentDiceRoll != null
        ? currentDiceRoll!.rollUnheld()
        : DiceRoll();

    return copyWith(
      currentDiceRoll: newRoll,
      currentRollsRemaining: currentRollsRemaining - 1,
    );
  }

  /// Toggles the held state of the die at [index].
  /// Returns a new [GameState] with the updated dice roll.
  GameState toggleDieHold(int index) {
    if (currentDiceRoll == null) return this;

    final dice = List<Die>.from(currentDiceRoll!.dice);
    dice[index] = dice[index].toggleHold();

    return copyWith(currentDiceRoll: DiceRoll(dice: dice));
  }

  /// Resets the current turn (rolls remaining and dice).
  GameState resetTurn() {
    return copyWith(
      currentRollsRemaining: _maxRolls,
      currentDiceRoll: null,
      selectedCategory: null,
    );
  }

  @override
  String toString() {
    return 'GameState(rolls: $currentRollsRemaining, '
        'dice: $currentDiceRoll, '
        'total: $totalScore, '
        'over: $isGameOver)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameState &&
        other.currentRollsRemaining == currentRollsRemaining &&
        other.currentDiceRoll == currentDiceRoll &&
        other.selectedCategory == selectedCategory &&
        other.scores.length == scores.length &&
        scores.entries.every((e) => other.scores[e.key] == e.value);
  }

  @override
  int get hashCode => Object.hash(
    currentRollsRemaining,
    currentDiceRoll,
    selectedCategory,
    Object.hashAllUnordered(scores.entries),
  );
}
