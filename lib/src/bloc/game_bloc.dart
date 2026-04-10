import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:poker_dice/src/domain/game_state.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';

/// Game state notifier that manages game logic and state changes.
///
/// This class handles all game interactions including:
/// - Rolling dice
/// - Holding/unholding dice
/// - Selecting categories to score
/// - Starting new games
class GameBloc extends ValueNotifier<GameState> {
  /// Stream controller for game events.
  final StreamController<String> _eventController =
      StreamController<String>.broadcast();

  /// Stream of game events for debugging/analytics.
  Stream<String> get eventStream => _eventController.stream;

  /// Creates a new GameBloc instance.
  ///
  /// [initialState] defaults to a new game if not specified.
  GameBloc({GameState? initialState}) : super(initialState ?? GameState());

  /// Rolls the dice if the game is not over and rolls are available.
  void rollDice() {
    if (value.isGameOver || !value.canRoll) {
      return;
    }

    try {
      value = value.rollDice();
      _emitEvent('dice_rolled');
    } catch (e) {
      _emitEvent('error: $e');
    }
  }

  /// Toggles the hold state of a die at the given index.
  ///
  /// [index] is the die index (0-4).
  void toggleDie(int index) {
    if (value.isGameOver) {
      return;
    }

    try {
      value = value.toggleDie(index);
      _emitEvent('die_toggled_$index');
    } catch (e) {
      _emitEvent('error: $e');
    }
  }

  /// Selects a category to score the current dice.
  ///
  /// [category] is the scoring category to apply.
  void selectCategory(ScoreCategory category) {
    if (value.isGameOver) {
      return;
    }

    try {
      value = value.selectCategory(category);
      _emitEvent('category_selected_${category.name}');
    } catch (e) {
      _emitEvent('error: $e');
    }
  }

  /// Commits/plays the selected category for scoring.
  ///
  /// This is called when the Play button is tapped.
  /// [category] is the scoring category to apply.
  void commitCategory(ScoreCategory category) {
    if (value.isGameOver) {
      return;
    }

    try {
      value = value.commitCategory(category);
      _emitEvent('category_committed_${category.name}');
    } catch (e) {
      _emitEvent('error: $e');
    }
  }

  /// Returns true if there are unscored categories available.
  bool get hasUnscoredCategories {
    return !value.isGameOver && value.getValidCategories().isNotEmpty;
  }

  /// Starts a new game.
  void newGame() {
    value = value.newGame();
    _emitEvent('new_game');
  }

  /// Calculates the potential score for a category.
  ///
  /// [category] is the category to calculate potential score for.
  int getPotentialScore(ScoreCategory category) {
    return value.getPotentialScore(category);
  }

  /// Emits a game event for debugging.
  void _emitEvent(String event) {
    if (!kDebugMode) return;
    _eventController.add(event);
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
