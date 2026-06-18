/// Game state provider using Riverpod's StateNotifier pattern.
///
/// Manages the lifecycle of a single poker dice game session,
/// including rolling dice, holding dice, scoring categories,
/// and game flow transitions.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/services/dice_roller.dart';
import 'package:poker_dice/services/scoring_service.dart';

/// Riverpod provider that exposes the [GameNotifier].
///
/// The notifier holds a single [GameState] instance and exposes
/// imperative methods to mutate that state in a controlled way.
final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(),
);

/// StateNotifier responsible for all game state mutations.
///
/// Delegates dice rolling to [DiceRoller] and scoring to
/// [ScoringService]. On every state change, [autoSave] is
/// invoked (currently a no-op stub).
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier({GameState? initialState}) : super(initialState ?? GameState()) {
    // Only reset turn when creating a fresh game, not when an initial state
    // is explicitly provided (e.g. for testing).
    if (initialState == null) {
      _resetTurn();
    }
  }

  final DiceRoller _diceRoller = DiceRoller();
  final ScoringService _scoringService = ScoringService();

  /// Rolls all unheld dice, consuming one roll.
  ///
  /// Does nothing if the game is completed or no rolls remain.
  void rollDice() {
    if (state.status == GameStatus.completed || state.rollsRemaining <= 0) {
      return;
    }

    final rolledDice = _diceRoller.rollDice();
    final updatedDice = <Dice>[];
    int rollIndex = 0;

    for (int i = 0; i < state.currentDice.length; i++) {
      if (state.currentDice[i].isHeld) {
        updatedDice.add(state.currentDice[i]);
      } else {
        updatedDice.add(Dice(value: rolledDice[rollIndex].value));
        rollIndex++;
      }
    }

    try {
      state = state.rollDice(updatedDice);
      _autoSave(state);
    } on StateError {
      // No rolls remaining, ignore.
    } on ArgumentError {
      // Invalid dice count, ignore.
    }
  }

  /// Toggles the held state of the die at [index].
  ///
  /// Does nothing if the index is out of bounds.
  void toggleHold(int index) {
    try {
      state = state.toggleHold(index);
    } on RangeError {
      // Index out of bounds, ignore.
    }
  }

  /// Scores the [category] with the current dice and advances the turn.
  ///
  /// Does nothing if the category is already scored or the game is completed.
  void selectCategory(ScoreCategory category) {
    if (state.status == GameStatus.completed) {
      return;
    }

    if (state.scoredCategories[category] != null) {
      return;
    }

    final score = _scoringService.calculateScore(state.currentDice, category);

    try {
      state = state.scoreCategory(category, score);
      _autoSave(state);
      // Reset turn after scoring
      if (state.status == GameStatus.active) {
        _resetTurn();
      }
    } on StateError {
      // Category already scored, ignore.
    }
  }

  /// Resets the game to a fresh state.
  void resetGame() {
    state = GameState();
    _resetTurn();
  }

  /// Returns the preview score for [category] with current dice.
  ///
  /// Returns `null` if the category is already scored.
  int? getPreviewScore(ScoreCategory category) {
    if (state.scoredCategories[category] != null) {
      return null;
    }
    return _scoringService.calculateScore(state.currentDice, category);
  }

  // -- Private helpers -----------------------------------------------------

  /// Resets dice and rolls for a new turn.
  void _resetTurn() {
    state = state.copyWith(
      currentDice: List.generate(5, (_) => Dice(value: 1)),
      rollsRemaining: 3,
    );
  }

  /// Placeholder for persistence layer.
  ///
  /// Currently a no-op; will be replaced with shared_preferences or
  /// local database integration in a future iteration.
  void _autoSave(GameState gameState) {
    // Stub: persist gameState to local storage.
  }
}
