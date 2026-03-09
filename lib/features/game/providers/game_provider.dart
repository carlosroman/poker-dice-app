import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/dice_faces.dart';
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
  /// The turn remains active after rolling. The user must select a score category
  /// to end the turn. When rolls reach 0, the roll button is disabled but the
  /// turn stays active until a score is selected.
  void rollDice() {
    if (!state.isTurnActive || state.rollsRemaining <= 0) {
      return;
    }

    final updatedDice = List<Dice>.from(state.dice);
    for (int i = 0; i < updatedDice.length; i++) {
      if (!updatedDice[i].isHeld) {
        updatedDice[i] = updatedDice[i].roll();
      }
    }

    final rollsRemaining = state.rollsRemaining - 1;

    state = GameState(
      dice: updatedDice,
      rollsRemaining: rollsRemaining,
      isTurnActive: true,
      scoreCategories: state.scoreCategories,
      turnNumber: state.turnNumber,
      isGameOver: state.isGameOver,
    );
  }

  /// Toggles the hold state for the dice at the specified index.
  ///
  /// [diceIndex] - The index of the dice to toggle (0-4).
  void toggleHold(int diceIndex) {
    if (diceIndex < 0 || diceIndex >= state.dice.length) {
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

  /// Scores a category and advances the turn.
  ///
  /// [categoryIndex] - The index of the category to score (0-12).
  /// [score] - The score value to assign to the category.
  ///
  /// If all categories are filled after scoring, the game ends.
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
      );
    } else {
      _endTurn();
    }
  }

  /// Resets the game to start a new game.
  void resetGame() {
    state = GameState();
  }

  /// Calculates potential scores for all categories based on current dice.
  ///
  /// [diceValues] - List of dice values (0-5) to calculate scores for.
  ///
  /// Returns a list of 13 integers representing potential scores for each category.
  ///
  /// Category order:
  /// - Index 0-5: Upper section (9s, 10s, Js, Qs, Ks, As)
  /// - Index 6: Three of a Kind
  /// - Index 7: Four of a Kind
  /// - Index 8: Full House
  /// - Index 9: Sm. Straight (30 points for 4 consecutive)
  /// - Index 10: Lg. Straight (40 points for 5 consecutive)
  /// - Index 11: Yahtzee (50 points for 5 of a kind)
  /// - Index 12: Bonus
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
    );
  }
}
