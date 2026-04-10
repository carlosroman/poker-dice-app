import 'models/game_round.dart';
import 'models/score_category.dart';
import 'models/score_sheet.dart';

/// Represents the complete state of a poker dice game.
///
/// Manages the current round, score sheet, and game progress.
/// This class is immutable - all methods return new instances.
class GameState {
  /// The current round of the game.
  final GameRound currentRound;

  /// The score sheet tracking all scored categories.
  final ScoreSheet scoreSheet;

  /// Whether the game is over.
  final bool isGameOver;

  /// Creates a new GameState instance.
  ///
  /// [currentRound] defaults to a new round if not specified.
  /// [scoreSheet] defaults to an empty score sheet if not specified.
  /// [isGameOver] defaults to false if not specified.
  GameState({GameRound? currentRound, ScoreSheet? scoreSheet, bool? isGameOver})
    : currentRound = currentRound ?? GameRound(),
      scoreSheet = scoreSheet ?? const ScoreSheet(),
      isGameOver = isGameOver ?? false;

  /// Creates a copy of this GameState with optional new values.
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

  /// Rolls the unheld dice in the current round.
  ///
  /// Returns a new [GameState] with the updated round.
  /// Throws [StateError] if maximum rolls have been reached.
  GameState rollDice() {
    if (isGameOver) {
      throw StateError('Cannot roll: game is over');
    }

    final heldDiceIndices = currentRound.dice
        .asMap()
        .entries
        .where((entry) => entry.value.held)
        .map((entry) => entry.key)
        .toList();

    final newRound = currentRound.rollDice(keptIndices: heldDiceIndices);
    return copyWith(currentRound: newRound);
  }

  /// Toggles the held state of the die at the given index.
  ///
  /// [index] is the index of the die to toggle (0-4).
  /// Returns a new [GameState] with the updated round.
  /// Throws [RangeError] if index is out of bounds.
  GameState toggleDie(int index) {
    if (isGameOver) {
      throw StateError('Cannot toggle die: game is over');
    }

    final newRound = currentRound.toggleDie(index);
    return copyWith(currentRound: newRound);
  }

  /// Scores the selected category and starts a new round if the game is not over.
  ///
  /// [category] is the scoring category to apply.
  /// Returns a new [GameState] with the updated score sheet.
  /// Throws [ArgumentError] if category is already scored.
  /// Throws [StateError] if game is over.
  GameState selectCategory(ScoreCategory category) {
    if (isGameOver) {
      throw StateError('Cannot select category: game is over');
    }

    if (scoreSheet.isCategoryScored(category)) {
      throw ArgumentError('Category $category is already scored');
    }

    final diceValues = currentRound.dice.map((die) => die.value).toList();
    final newScoreSheet = scoreSheet.score(category, diceValues);
    final isComplete = newScoreSheet.isComplete;

    if (isComplete) {
      return copyWith(scoreSheet: newScoreSheet, isGameOver: true);
    }

    final newRound = GameRound();
    return copyWith(scoreSheet: newScoreSheet, currentRound: newRound);
  }

  /// Commits/play the selected category for scoring.
  ///
  /// This is an alias for [selectCategory] used for the Play button.
  /// [category] is the scoring category to apply.
  /// Returns a new [GameState] with the updated score sheet.
  GameState commitCategory(ScoreCategory category) {
    return selectCategory(category);
  }

  /// Resets the game state to initial values.
  ///
  /// Returns a new [GameState] representing a fresh game.
  GameState newGame() {
    return GameState();
  }

  /// Returns the list of categories that can be scored.
  ///
  /// These are categories that haven't been scored yet.
  List<ScoreCategory> getValidCategories() {
    return scoreSheet.getEmptyCategories();
  }

  /// Calculates the potential score for a category without scoring it.
  ///
  /// [category] is the category to calculate potential score for.
  /// Returns the score that would be obtained if this category were selected now.
  /// Returns 0 if category is already scored or game is over.
  int getPotentialScore(ScoreCategory category) {
    if (isGameOver || scoreSheet.isCategoryScored(category)) {
      return 0;
    }

    final diceValues = currentRound.dice.map((die) => die.value).toList();

    if (category.isMinor) {
      return ScoreSheet.allCategories.contains(category)
          ? _calculateMinorPotential(category, diceValues)
          : 0;
    }

    return _calculateMajorPotential(category, diceValues);
  }

  int _calculateMinorPotential(ScoreCategory category, List<int> diceValues) {
    switch (category) {
      case ScoreCategory.aces:
        return diceValues
            .where((die) => die == 1)
            .fold(0, (sum, die) => sum + die);
      case ScoreCategory.twos:
        return diceValues
            .where((die) => die == 2)
            .fold(0, (sum, die) => sum + die);
      case ScoreCategory.threes:
        return diceValues
            .where((die) => die == 3)
            .fold(0, (sum, die) => sum + die);
      case ScoreCategory.fours:
        return diceValues
            .where((die) => die == 4)
            .fold(0, (sum, die) => sum + die);
      case ScoreCategory.fives:
        return diceValues
            .where((die) => die == 5)
            .fold(0, (sum, die) => sum + die);
      case ScoreCategory.sixes:
        return diceValues
            .where((die) => die == 6)
            .fold(0, (sum, die) => sum + die);
      default:
        return 0;
    }
  }

  int _calculateMajorPotential(ScoreCategory category, List<int> diceValues) {
    switch (category) {
      case ScoreCategory.threeOfKind:
        return _calculateThreeOfKindPotential(diceValues);
      case ScoreCategory.fourOfKind:
        return _calculateFourOfKindPotential(diceValues);
      case ScoreCategory.fullHouse:
        return _calculateFullHousePotential(diceValues);
      case ScoreCategory.smallStraight:
        return _calculateSmallStraightPotential(diceValues);
      case ScoreCategory.largeStraight:
        return _calculateLargeStraightPotential(diceValues);
      case ScoreCategory.yatzy:
        return _calculateYatzyPotential(diceValues);
      case ScoreCategory.chance:
        return diceValues.fold(0, (sum, die) => sum + die);
      default:
        return 0;
    }
  }

  int _calculateThreeOfKindPotential(List<int> diceValues) {
    final counts = _countDice(diceValues);
    for (final count in counts.values) {
      if (count >= 3) {
        return diceValues.fold(0, (sum, die) => sum + die);
      }
    }
    return 0;
  }

  int _calculateFourOfKindPotential(List<int> diceValues) {
    final counts = _countDice(diceValues);
    for (final count in counts.values) {
      if (count >= 4) {
        return diceValues.fold(0, (sum, die) => sum + die);
      }
    }
    return 0;
  }

  int _calculateFullHousePotential(List<int> diceValues) {
    final counts = _countDice(diceValues);
    final values = counts.values.toList();
    final hasThree = values.contains(3);
    final hasTwo = values.contains(2);

    if (hasThree && hasTwo) {
      return 25;
    }
    return 0;
  }

  int _calculateSmallStraightPotential(List<int> diceValues) {
    final uniqueDice = diceValues.toSet().toList()..sort();
    int consecutive = 1;

    for (int i = 1; i < uniqueDice.length; i++) {
      if (uniqueDice[i] == uniqueDice[i - 1] + 1) {
        consecutive++;
        if (consecutive >= 4) return 30;
      } else {
        consecutive = 1;
      }
    }
    return 0;
  }

  int _calculateLargeStraightPotential(List<int> diceValues) {
    final uniqueDice = diceValues.toSet().toList()..sort();
    if (uniqueDice.length != 5) return 0;

    int consecutive = 1;
    for (int i = 1; i < uniqueDice.length; i++) {
      if (uniqueDice[i] == uniqueDice[i - 1] + 1) {
        consecutive++;
        if (consecutive >= 5) return 40;
      } else {
        return 0;
      }
    }
    return 0;
  }

  int _calculateYatzyPotential(List<int> diceValues) {
    if (diceValues.isEmpty) return 0;
    final first = diceValues.first;
    if (diceValues.every((die) => die == first)) {
      return 50 + (scoreSheet.yatzyCount * 50);
    }
    return 0;
  }

  Map<int, int> _countDice(List<int> dice) {
    final counts = <int, int>{};
    for (final die in dice) {
      counts[die] = (counts[die] ?? 0) + 1;
    }
    return counts;
  }

  /// Returns the total score.
  int get totalScore => scoreSheet.getTotal();

  /// Returns the current dice values.
  List<int> get diceValues =>
      currentRound.dice.map((die) => die.value).toList();

  /// Returns whether more rolls are available in the current round.
  bool get canRoll => currentRound.canRoll();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameState) return false;

    return other.currentRound == currentRound &&
        other.scoreSheet == scoreSheet &&
        other.isGameOver == isGameOver;
  }

  @override
  int get hashCode => Object.hash(currentRound, scoreSheet, isGameOver);

  @override
  String toString() {
    return 'GameState(currentRound: $currentRound, scoreSheet: $scoreSheet, isGameOver: $isGameOver)';
  }
}
