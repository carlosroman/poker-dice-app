import 'dice.dart';
import 'score_category.dart';

/// The current status of a game session.
enum GameStatus {
  /// Game is in progress.
  active,

  /// All 13 categories have been scored.
  completed,
}

/// Holds all mutable state for a single round of poker dice.
///
/// Tracks the five dice, remaining rolls, scored categories, and derived
/// totals (upper section, bonus, grand total).
class GameState {
  /// The five dice currently on the table.
  final List<Dice> currentDice;

  /// Number of rolls left for the current round (starts at 3).
  final int rollsRemaining;

  /// Scores already committed to each category.
  /// `null` means the category has not been scored yet.
  final Map<ScoreCategory, int?> scoredCategories;

  /// The overall status of the game.
  final GameStatus status;

  /// Category currently selected for preview (pending confirmation).
  final ScoreCategory? selectedCategory;

  /// Creates a [GameState] with the given values.
  ///
  /// Throws an [ArgumentError] if [currentDice] does not contain exactly 5 dice.
  GameState({
    List<Dice>? currentDice,
    this.rollsRemaining = 3,
    Map<ScoreCategory, int?>? scoredCategories,
    this.status = GameStatus.active,
    this.selectedCategory,
  }) : currentDice = currentDice ?? List.generate(5, (_) => Dice(value: 1)),
       scoredCategories =
           scoredCategories ??
           {for (final category in ScoreCategory.values) category: null} {
    if (this.currentDice.length != 5) {
      throw ArgumentError(
        'Exactly 5 dice are required, got ${this.currentDice.length}.',
      );
    }
  }

  /// Creates a fresh game state with default values.
  factory GameState.initial() {
    return GameState();
  }

  /// Sum of scored upper-section categories (Aces through Sixes).
  int get upperSectionTotal {
    int total = 0;
    for (final entry in scoredCategories.entries) {
      if (entry.key.isUpper && entry.value != null) {
        total += entry.value!;
      }
    }
    return total;
  }

  /// Whether the upper-section bonus (35 points) applies.
  ///
  /// Bonus is awarded when the upper section total is 63 or more.
  bool get hasBonus => upperSectionTotal >= 63;

  /// Bonus points: 35 if [hasBonus] is true, otherwise 0.
  int get bonus => hasBonus ? 35 : 0;

  /// Total score across all scored categories plus bonus.
  int get totalScore {
    int total = scoredCategories.values.whereType<int>().fold(
      0,
      (sum, score) => sum + score,
    );
    return total + bonus;
  }

  /// Whether all 13 categories have been scored.
  bool get isGameComplete {
    return scoredCategories.values.every((score) => score != null);
  }

  /// Replaces the current dice with [newDice] and decrements [rollsRemaining].
  ///
  /// Throws an [ArgumentError] if [newDice] does not contain exactly 5 dice.
  /// Throws a [StateError] if no rolls remain.
  GameState rollDice(List<Dice> newDice) {
    if (newDice.length != 5) {
      throw ArgumentError('Expected 5 dice, got ${newDice.length}.');
    }
    if (rollsRemaining <= 0) {
      throw StateError('No rolls remaining.');
    }
    return copyWith(currentDice: newDice, rollsRemaining: rollsRemaining - 1);
  }

  /// Toggles the held state of the die at [index].
  ///
  /// Throws a [RangeError] if [index] is out of bounds.
  GameState toggleHold(int index) {
    if (index < 0 || index >= currentDice.length) {
      throw RangeError.range(index, 0, currentDice.length - 1, 'index');
    }
    final updatedDice = List<Dice>.from(currentDice);
    final die = updatedDice[index];
    updatedDice[index] = die.copyWith(isHeld: !die.isHeld);
    return copyWith(currentDice: updatedDice);
  }

  /// Records a [score] for the given [category].
  ///
  /// Throws a [StateError] if the category has already been scored.
  GameState scoreCategory(ScoreCategory category, int score) {
    if (scoredCategories[category] != null) {
      throw StateError('${category.displayName} has already been scored.');
    }
    final updated = Map<ScoreCategory, int?>.from(scoredCategories);
    updated[category] = score;
    final newStatus = updated.values.every((s) => s != null)
        ? GameStatus.completed
        : status;
    return copyWith(scoredCategories: updated, status: newStatus);
  }

  /// Returns a copy of this state with the specified fields replaced.
  GameState copyWith({
    List<Dice>? currentDice,
    int? rollsRemaining,
    Map<ScoreCategory, int?>? scoredCategories,
    GameStatus? status,
    ScoreCategory? selectedCategory,
    bool clearSelectedCategory = false,
  }) {
    return GameState(
      currentDice: currentDice ?? this.currentDice,
      rollsRemaining: rollsRemaining ?? this.rollsRemaining,
      scoredCategories: scoredCategories ?? this.scoredCategories,
      status: status ?? this.status,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
    );
  }
}
