import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/category.dart';
import '../models/dice_roll.dart';
import '../models/die.dart';
import '../models/game_state.dart';
import '../services/scoring_service.dart';
import '../services/storage_service.dart';

/// StateNotifier that manages the game state for Poker Dice.
///
/// This class handles all game logic including:
/// - Starting new games and turns
/// - Rolling dice and toggling held state
/// - Scoring categories using [ScoringService]
/// - Tracking game progression and game over state
class GameNotifier extends StateNotifier<GameState> {
  /// Service for calculating scores for all categories.
  final ScoringService _scoringService;

  /// Creates a new GameNotifier with the specified [scoringService].
  ///
  /// If [scoringService] is not provided, a default instance is created.
  GameNotifier({ScoringService? scoringService})
    : _scoringService = scoringService ?? ScoringService(),
      super(GameState());

  /// Starts a fresh game with no scores and 3 rolls remaining.
  ///
  /// Resets all game state including scores, turns, and dice.
  /// Dice are null initially until first roll.
  void startNewGame() {
    state = GameState(
      diceRoll: null,
      scores: {},
      selectedCategory: null,
      remainingRolls: GameState.maxRollsPerTurn,
      currentTurn: 1,
      isGameOver: false,
      upperSectionTotal: 0,
      bonusAwarded: false,
      totalScore: 0,
    );
  }

  /// Starts a new turn by rolling dice and resetting rolls to 3.
  ///
  /// If the game is over, this method does nothing.
  void startTurn() {
    if (state.isGameOver) return;
    state = GameState(
      diceRoll: DiceRoll.random(),
      scores: Map.from(state.scores),
      selectedCategory: null,
      remainingRolls: GameState.maxRollsPerTurn,
      currentTurn: state.currentTurn,
      isGameOver: false,
      upperSectionTotal: state.upperSectionTotal,
      bonusAwarded: state.bonusAwarded,
      totalScore: state.totalScore,
    );
  }

  /// Toggles the held state of the die at the specified [index].
  ///
  /// The [index] must be between 0 and 4 (inclusive).
  /// Does nothing if no dice roll is currently active.
  void toggleDieHeld(int index) {
    if (state.diceRoll == null) return;
    state = GameState(
      diceRoll: state.diceRoll!.toggleDieHeld(index),
      scores: Map.from(state.scores),
      selectedCategory: state.selectedCategory,
      remainingRolls: state.remainingRolls,
      currentTurn: state.currentTurn,
      isGameOver: state.isGameOver,
      upperSectionTotal: state.upperSectionTotal,
      bonusAwarded: state.bonusAwarded,
      totalScore: state.totalScore,
    );
  }

  /// Rolls all unheld dice if rolls remain.
  ///
  /// Decrements [remainingRolls] by 1.
  /// Does nothing if no rolls remain.
  void rollDice() {
    if (state.remainingRolls <= 0) return;
    state = GameState(
      diceRoll: state.diceRoll?.rollUnheldDice() ?? DiceRoll.random(),
      scores: Map.from(state.scores),
      selectedCategory: state.selectedCategory,
      remainingRolls: state.remainingRolls - 1,
      currentTurn: state.currentTurn,
      isGameOver: state.isGameOver,
      upperSectionTotal: state.upperSectionTotal,
      bonusAwarded: state.bonusAwarded,
      totalScore: state.totalScore,
    );
  }

  /// Selects a [category] for scoring.
  ///
  /// Only unscored categories can be selected.
  /// Does nothing if the category is already scored.
  void selectCategory(Category category) {
    if (state.scores.containsKey(category)) return;
    state = GameState(
      diceRoll: state.diceRoll,
      scores: Map.from(state.scores),
      selectedCategory: category,
      remainingRolls: state.remainingRolls,
      currentTurn: state.currentTurn,
      isGameOver: state.isGameOver,
      upperSectionTotal: state.upperSectionTotal,
      bonusAwarded: state.bonusAwarded,
      totalScore: state.totalScore,
    );
  }

  /// Scores the specified [category] using the [ScoringService].
  ///
  /// The [selectedCategory] must be set before calling this method.
  /// If [category] differs from [selectedCategory], uses [category] instead.
  /// Does nothing if the category is already scored.
  void scoreCategory(Category category) {
    if (state.diceRoll == null) return;
    if (state.scores.containsKey(category)) return;

    final int score = _scoringService.score(category, state.diceRoll!);
    state = state.scoreCategory(category, score);
  }

  /// Resets the game to initial state.
  ///
  /// Equivalent to [startNewGame].
  void resetGame() {
    startNewGame();
  }

  /// Restores game state from a saved state map.
  ///
  /// Used when continuing a previously saved game.
  void restoreGameState(Map<String, dynamic> savedState) {
    try {
      // Parse dice roll if present
      DiceRoll? diceRoll;
      if (savedState['diceRoll'] != null) {
        final diceList = savedState['diceRoll'] as List<dynamic>;
        final dice = diceList
            .map(
              (d) => Die(value: d['value'] as int, isHeld: d['isHeld'] as bool),
            )
            .toList();
        diceRoll = DiceRoll(dice);
      }

      // Parse scores
      final scores = <Category, int>{};
      if (savedState['scores'] != null) {
        final scoresMap = savedState['scores'] as Map<String, dynamic>;
        scoresMap.forEach((key, value) {
          final categoryIndex = int.parse(key);
          scores[Category.values[categoryIndex]] = value as int;
        });
      }

      // Parse selected category
      Category? selectedCategory;
      if (savedState['selectedCategory'] != null) {
        selectedCategory =
            Category.values[savedState['selectedCategory'] as int];
      }

      state = GameState(
        diceRoll: diceRoll,
        scores: scores,
        selectedCategory: selectedCategory,
        remainingRolls: savedState['remainingRolls'] as int? ?? 3,
        currentTurn: savedState['currentTurn'] as int? ?? 1,
        isGameOver: savedState['isGameOver'] as bool? ?? false,
        upperSectionTotal: savedState['upperSectionTotal'] as int? ?? 0,
        bonusAwarded: savedState['bonusAwarded'] as bool? ?? false,
        totalScore: savedState['totalScore'] as int? ?? 0,
      );
    } catch (e) {
      // If restoration fails, start a new game
      startNewGame();
    }
  }

  /// Saves the current game state to storage.
  ///
  /// This should be called whenever the game state changes.
  Future<void> saveGameState() async {
    final storageService = await StorageService.getInstance();
    final scoresMap = <String, dynamic>{};
    state.scores.forEach((key, value) {
      scoresMap['${key.index}'] = value;
    });
    final diceList = state.diceRoll?.dice
        .map((d) => {'value': d.value, 'isHeld': d.isHeld})
        .toList();
    final stateMap = {
      'diceRoll': diceList,
      'scores': scoresMap,
      'selectedCategory': state.selectedCategory?.index,
      'remainingRolls': state.remainingRolls,
      'currentTurn': state.currentTurn,
      'isGameOver': state.isGameOver,
      'upperSectionTotal': state.upperSectionTotal,
      'bonusAwarded': state.bonusAwarded,
      'totalScore': state.totalScore,
    };
    await storageService.saveGameState(stateMap);
  }
}

/// Main provider for game state management.
///
/// Provides access to the complete game state and all game actions.
/// Use this provider in widgets to read game state and trigger actions.
///
/// Example:
/// ```dart
/// final notifier = ref.read(gameProvider.notifier);
/// notifier.startNewGame();
///
/// final gameState = ref.watch(gameProvider);
/// ```
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((Ref ref) {
  return GameNotifier();
});

/// Provides the current dice roll.
///
/// Returns null if no dice roll is active (start of turn or game over).
final diceRollProvider = Provider<DiceRoll?>((Ref ref) {
  return ref.watch(gameProvider).diceRoll;
});

/// Provides the number of remaining rolls in the current turn.
///
/// Returns 0 if no dice roll is active.
final remainingRollsProvider = Provider<int>((Ref ref) {
  return ref.watch(gameProvider).remainingRolls;
});

/// Provides the currently selected category for scoring.
///
/// Returns null if no category is selected.
final selectedCategoryProvider = Provider<Category?>((Ref ref) {
  return ref.watch(gameProvider).selectedCategory;
});

/// Provides all scores as a map of category to score.
final scoresProvider = Provider<Map<Category, int>>((Ref ref) {
  return Map.from(ref.watch(gameProvider).scores);
});

/// Provides the total of upper section scores (before bonus).
///
/// Sums scores for categories: ones, twos, threes, fours, fives, sixes.
final upperSectionTotalProvider = Provider<int>((Ref ref) {
  return ref.watch(gameProvider).upperSectionTotal;
});

/// Provides whether the bonus (+35) has been awarded.
///
/// Returns true if upper section total >= 63.
final bonusAwardedProvider = Provider<bool>((Ref ref) {
  return ref.watch(gameProvider).bonusAwarded;
});

/// Provides the total score including bonus and lower section.
final totalScoreProvider = Provider<int>((Ref ref) {
  return ref.watch(gameProvider).totalScore;
});

/// Provides whether the game is over.
///
/// Returns true when all 14 categories have been scored.
final isGameOverProvider = Provider<bool>((Ref ref) {
  return ref.watch(gameProvider).isGameOver;
});

/// Provides a list of categories that have not been scored yet.
///
/// Useful for determining which categories are still available for scoring.
final remainingCategoriesProvider = Provider<List<Category>>((Ref ref) {
  return ref.watch(gameProvider).getRemainingCategories();
});
