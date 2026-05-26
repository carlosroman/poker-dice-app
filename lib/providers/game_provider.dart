import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/services/scoring_service.dart';

/// Provider that supplies a [ScoringService] instance.
final scoringServiceProvider = Provider<ScoringService>((ref) {
  return ScoringService();
});

/// StateNotifierProvider that manages [GameState] via [GameNotifier].
final gameNotifierProvider = StateNotifierProvider<GameNotifier, GameState>((
  ref,
) {
  final scoringService = ref.watch(scoringServiceProvider);
  return GameNotifier(scoringService);
});

/// Convenience alias to read the current [GameState] without the notifier.
final gameStateProvider = Provider<GameState>((ref) {
  return ref.watch(gameNotifierProvider);
});

/// Notifier that exposes game actions as imperative methods
/// while keeping [GameState] immutable.
class GameNotifier extends StateNotifier<GameState> {
  final ScoringService scoringService;

  GameNotifier(this.scoringService) : super(GameState());

  /// Rolls unheld dice (or creates the first roll), decrements rolls remaining.
  void rollDice() {
    state = state.rollDice();
  }

  /// Toggles the held state of the die at [index].
  void toggleDieHold(int index) {
    state = state.toggleDieHold(index);
  }

  /// Selects a [category] for scoring (highlights it in the UI).
  void selectCategory(Category category) {
    state = state.selectCategory(category);
  }

  /// Scores the given [category] using the current dice roll,
  /// then resets the turn (rolls back to 3, clears dice and selection).
  void scoreCategory(Category category) {
    final diceRoll = state.currentDiceRoll;
    if (diceRoll == null) return;
    if (state.scores[category] != null) return;

    final score = scoringService.scoreCategory(category, diceRoll);
    state = state.addScore(category, score).resetTurn();
  }

  /// Resets the game to a fresh [GameState].
  void newGame() {
    state = state.reset();
  }

  /// Returns true when there are rolls remaining.
  bool canRoll() {
    return state.currentRollsRemaining > 0;
  }

  /// Returns true when a category is selected and has not yet been scored.
  bool canScore() {
    final category = state.selectedCategory;
    if (category == null) return false;
    return state.scores[category] == null;
  }
}
