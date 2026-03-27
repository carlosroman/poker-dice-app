import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/dice_faces.dart';
import 'game_state_provider.dart';
import '../data/game_state_repository.dart';
import '../logic/scoring.dart';
import '../models/dice.dart';
import '../models/game_state.dart';

/// Provider for [GameNotifier].
///
/// Creates and manages the game state notifier for the poker dice game.
final gameProvider = NotifierProvider<GameNotifier, GameState>(
  () => GameNotifier(),
);

/// Game state notifier for managing poker dice game logic.
///
/// Handles dice rolling, holding, scoring, and turn management.
/// Extends [Notifier] for immutable state updates following Riverpod conventions.
class GameNotifier extends Notifier<GameState> {
  /// Creates a new [GameNotifier] instance.
  @override
  GameState build() {
    return GameState();
  }

  /// Rolls all non-held dice and decrements rolls remaining.
  ///
  /// The turn remains active after rolling. If there's a pending selection,
  /// it is cleared when rolling. When rolls reach 0, the roll button is disabled
  /// but the turn stays active until a score is confirmed.
  void rollDice() {
    if (!state.isTurnActive || state.rollsRemaining <= 0) {
      return;
    }

    // Clear any pending selection when rolling
    final stateWithoutPending = state.pendingSelection != null
        ? state.clearPendingSelection()
        : state;

    final updatedDice = List<Dice>.from(stateWithoutPending.dice);
    for (int i = 0; i < updatedDice.length; i++) {
      if (!updatedDice[i].isHeld) {
        updatedDice[i] = updatedDice[i].roll();
      }
    }

    final rollsRemaining = stateWithoutPending.rollsRemaining - 1;

    state = GameState(
      dice: updatedDice,
      rollsRemaining: rollsRemaining,
      isTurnActive: true,
      scoreCategories: stateWithoutPending.scoreCategories,
      turnNumber: stateWithoutPending.turnNumber,
      isGameOver: stateWithoutPending.isGameOver,
      pendingSelection: null,
    );
  }

  /// Toggles the hold state for the dice at the specified index.
  ///
  /// [diceIndex] - The index of the dice to toggle (0-4).
  void toggleHold(int diceIndex) {
    if (diceIndex < 0 || diceIndex >= state.dice.length) {
      return;
    }

    // Don't allow holding dice that haven't been rolled yet
    if (state.dice[diceIndex].value == null) {
      return;
    }

    final updatedDice = List<Dice>.from(state.dice);
    updatedDice[diceIndex] = updatedDice[diceIndex].toggleHold();

    state = GameState(
      dice: updatedDice,
      rollsRemaining: state.rollsRemaining,
      isTurnActive: state.isTurnActive,
      scoreCategories: state.scoreCategories,
      turnNumber: state.turnNumber,
      isGameOver: state.isGameOver,
    );
  }

  /// Sets a category as pending selection (not yet scored).
  ///
  /// [categoryIndex] - The index of the category to select (0-12).
  ///
  /// This marks the category as pending, waiting for confirmation via [confirmSelection].
  /// If [categoryIndex] is -1 or null, clears any pending selection.
  void selectPending(int categoryIndex) {
    if (categoryIndex < -1 || categoryIndex >= state.scoreCategories.length) {
      return;
    }

    // Can't select an already scored category
    if (categoryIndex >= 0 && state.isCategoryScored(categoryIndex)) {
      return;
    }

    state = state.selectPending(categoryIndex == -1 ? null : categoryIndex);
  }

  /// Confirms the pending selection and scores the category.
  ///
  /// If there's a pending selection, it will be scored with its potential score
  /// and the turn will end. If no pending selection exists, does nothing.
  ///
  /// If all categories are filled after scoring, the game ends.
  void confirmSelection() {
    final pendingIndex = state.pendingSelection;

    // No pending selection to confirm
    if (pendingIndex == null) {
      return;
    }

    // Can't confirm an already scored category
    if (state.isCategoryScored(pendingIndex)) {
      state = state.clearPendingSelection();
      return;
    }

    // Calculate the score for the pending category
    final diceValues = state.dice.map((d) => d.value ?? 0).toList();
    final potentialScores = getPotentialScores(diceValues);
    final score = potentialScores[pendingIndex];

    state = state.fillCategory(pendingIndex, score);

    if (state.categoriesRemaining() <= 1) {
      state = GameState(
        dice: state.dice,
        rollsRemaining: state.rollsRemaining,
        isTurnActive: false,
        scoreCategories: state.scoreCategories,
        turnNumber: state.turnNumber,
        isGameOver: true,
        pendingSelection: null,
      );
    } else {
      _endTurn();
    }
  }

  /// Scores a category and advances the turn (legacy method, use [selectPending] + [confirmSelection]).
  ///
  /// [categoryIndex] - The index of the category to score (0-13).
  /// [score] - The score value to assign to the category.
  ///
  /// If all categories are filled after scoring, the game ends.
  ///
  /// This method maintains backward compatibility by directly scoring the category
  /// with the provided score value, bypassing the two-step flow.
  @Deprecated('Use selectPending() followed by confirmSelection() instead')
  void selectScore(int categoryIndex, int score) {
    if (categoryIndex < 0 || categoryIndex >= state.scoreCategories.length) {
      return;
    }

    if (state.isCategoryScored(categoryIndex)) {
      return;
    }

    state = state.fillCategory(categoryIndex, score);

    if (state.categoriesRemaining() <= 1) {
      state = GameState(
        dice: state.dice,
        rollsRemaining: state.rollsRemaining,
        isTurnActive: false,
        scoreCategories: state.scoreCategories,
        turnNumber: state.turnNumber,
        isGameOver: true,
        pendingSelection: null,
      );
    } else {
      _endTurn();
    }
  }

  /// Resets the game to start a new game.
  void resetGame() {
    state = GameState();
  }

  /// Loads the game from a saved [GameState].
  ///
  /// This method restores the game state from a previously saved state,
  /// allowing the user to continue from where they left off.
  void loadFromSavedState(GameState savedState) {
    state = savedState;
  }

  /// Saves the current game state to persistence.
  ///
  /// Uses the [GameStateRepository] to persist the current state.
  /// Returns a [Future] that completes when the save is done.
  Future<bool> saveState() async {
    final notifier = ref.read(gameStateProvider.notifier);
    final success = await notifier.saveGameState(state);
    return success;
  }

  /// Clears the saved game state from persistence.
  ///
  /// This is called when a new game starts or when the game ends.
  /// Returns a [Future] that completes when the clear is done.
  Future<bool> clearSavedState() async {
    return await ref.read(gameStateRepositoryProvider).clearGameState();
  }

  /// Calculates potential scores for all categories based on current dice.
  ///
  /// [diceValues] - List of dice values (0-5) to calculate scores for.
  ///
  /// Returns a list of 14 integers representing potential scores for each category.
  ///
  /// Category order:
  /// - Index 0-5: Upper section (9s, 10s, Js, Qs, Ks, As)
  /// - Index 6: Three of a Kind
  /// - Index 7: Four of a Kind
  /// - Index 8: Full House
  /// - Index 9: Sm. Straight (30 points for 4 consecutive)
  /// - Index 10: Lg. Straight (40 points for 5 consecutive)
  /// - Index 11: Yahtzee (50 points for 5 of a kind)
  /// - Index 12: Chance (sum of all dice)
  /// - Index 13: Bonus
  List<int> getPotentialScores(List<int> diceValues) {
    if (diceValues.length != NUM_DICE) {
      throw ArgumentError('diceValues must contain exactly 5 values');
    }

    return [
      Scoring.score9s(diceValues),
      Scoring.score10s(diceValues),
      Scoring.scoreJs(diceValues),
      Scoring.scoreQs(diceValues),
      Scoring.scoreKs(diceValues),
      Scoring.scoreAs(diceValues),
      Scoring.scoreThreeOfAKind(diceValues),
      Scoring.scoreFourOfAKind(diceValues),
      Scoring.scoreFullHouse(diceValues),
      Scoring.scoreSmallStraight(diceValues),
      Scoring.scoreLongStraight(diceValues),
      Scoring.scoreYatzy(diceValues),
      Scoring.scoreChance(diceValues),
      0, // Bonus
    ];
  }

  /// Ends the current turn and starts a new one.
  void _endTurn() {
    state = GameState(
      dice: List.generate(NUM_DICE, (_) => Dice()),
      rollsRemaining: MAX_ROLLS,
      isTurnActive: true,
      scoreCategories: state.scoreCategories,
      turnNumber: state.turnNumber + 1,
      isGameOver: state.isGameOver,
      pendingSelection: null,
    );
  }
}
