import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/animations/dice_roll_animation.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/services/dice_service.dart';

/// Manages game state using ChangeNotifier pattern.
///
/// Provides methods to roll dice, score categories, switch players,
/// and manage game flow.
class GameNotifier extends ChangeNotifier {
  final DiceService _diceService;
  final Duration _rollAnimationDelay;

  GameState _state;

  /// Creates a new game notifier.
  GameNotifier({
    DiceService? diceService,
    GameState? initialState,
    Duration? rollAnimationDelay,
  })  : _diceService = diceService ?? const DiceService(),
        _rollAnimationDelay = rollAnimationDelay ?? DieRollAnimation.duration,
        _state = initialState ?? const GameState();


  /// The current game state.
  GameState get state => _state;

  /// Rolls the dice and updates the game state.
  Future<void> rollDice() async {
    if (_state.currentRollsRemaining <= 0) return;

    final dice = _diceService.rollDice(5);
    _state = _state.rollDice(dice).decrementRolls();
    notifyListeners();

    // Skip animation delay in tests (Duration.zero)
    if (_rollAnimationDelay > Duration.zero) {
      await Future.delayed(_rollAnimationDelay);
    }
    if (_state.isRolling) {
      _state = _state.copyWith(isRolling: false);
      notifyListeners();
    }
  }

  /// Scores a category for the current player.
  void scoreCategory(String category) {
    if (_state.selectedCategory == null) return;

    // TODO: Calculate actual score based on dice values
    final score = 0;
    _state = _state.addScore(category, score).resetTurn();
    notifyListeners();
  }

  /// Selects a category for scoring.
  void selectCategory(String? category) {
    _state = _state.selectCategory(category);
    notifyListeners();
  }

  /// Decrements the remaining rolls and notifies listeners.
  void decrementRolls() {
    _state = _state.decrementRolls();
    notifyListeners();
  }

  /// Starts a new game.
  void newGame() {
    _state = _state.reset();
    notifyListeners();
  }

  /// Ends the current game.
  void endGame() {
    _state = _state.endGame();
    notifyListeners();
  }

  /// Resets the game to initial state.
  void resetGame() {
    _state = _state.reset();
    notifyListeners();
  }

  /// Resets the current turn (clears dice roll).
  void resetTurn() {
    _state = _state.resetTurn();
    notifyListeners();
  }

  /// Toggles the held state of a die at the given index.
  ///
  /// Dice can only be held when:
  /// - Dice have been rolled ([GameState.diceRoll] is not null)
  /// - Not currently rolling ([GameState.isRolling] is false)
  /// - Rolls remain ([GameState.currentRollsRemaining] > 0)
  void toggleHeldDice(int index) {
    _state = _state.toggleHeldDie(index);
    notifyListeners();
  }
}

/// Provider for the [GameNotifier] instance.
final gameNotifierProvider = ChangeNotifierProvider<GameNotifier>((ref) {
  return GameNotifier();
});

/// Provider for the current [GameState].
final gameStateProvider = Provider<GameState>((ref) {
  return ref.watch(gameNotifierProvider).state;
});
