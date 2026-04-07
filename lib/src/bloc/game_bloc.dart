import 'dart:developer' show log;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/game_state.dart';
import '../domain/models/score_category.dart';

/// Base class for all game events in the Poker Dice game.
///
/// Events represent user interactions and game actions that trigger
/// state changes. All events extend this sealed class for type safety.
///
/// See also:
/// - [RollDiceEvent]: Triggered when rolling dice
/// - [ToggleDieEvent]: Triggered when holding/unholding a die
/// - [SelectCategoryEvent]: Triggered when scoring a category
/// - [NewGameEvent]: Triggered when starting a new game
sealed class GameEvent {}

/// Event triggered when the player wants to roll the dice.
///
/// This event initiates a dice roll in the current round.
/// The handler validates that rolls are available before proceeding.
///
/// **Behavior:**
/// - First roll from [GameInitial] transitions to [GamePlaying] state
/// - Subsequent rolls update the current round
/// - No action if max rolls (3) are reached
/// - No action if game is over
///
/// Example:
/// ```dart
/// bloc.add(RollDiceEvent());
/// ```
class RollDiceEvent extends GameEvent {}

/// Event triggered when the player toggles a die's hold state.
///
/// Holding a die prevents it from being rolled in subsequent rolls.
/// Players use this to keep desirable dice values while re-rolling others.
///
/// Parameters:
/// - [index]: The index of the die to toggle (0-4).
///
/// **Behavior:**
/// - Toggles the hold state of the die at the given index
/// - No action if game is over
/// - Logs error for invalid indices
///
/// Example:
/// ```dart
/// bloc.add(ToggleDieEvent(0)); // Toggle hold state of first die
/// ```
class ToggleDieEvent extends GameEvent {
  /// The index of the die to toggle (0-4).
  ///
  /// Valid indices are 0, 1, 2, 3, or 4, corresponding to the 5 dice.
  final int index;

  /// Creates a [ToggleDieEvent].
  ///
  /// Parameters:
  /// - [index]: The die index to toggle (must be 0-4).
  ///
  /// Throws:
  /// No exceptions are thrown, but invalid indices are logged and ignored.
  ToggleDieEvent(this.index);
}

/// Event triggered when the player selects a category to score.
///
/// This event scores the selected category using the current dice values
/// and transitions to a new round (or ends the game if all categories scored).
///
/// Parameters:
/// - [category]: The category to score.
///
/// **Behavior:**
/// - Calculates and stores the score for the category
/// - Starts a new round with fresh dice
/// - Transitions to [GameOver] if all categories are scored
/// - Throws [StateError] if category is already scored
///
/// Example:
/// ```dart
/// bloc.add(SelectCategoryEvent(ScoreCategory.aces));
/// ```
class SelectCategoryEvent extends GameEvent {
  /// The category to score.
  ///
  /// Must be an unscored category from the current valid categories.
  final ScoreCategory category;

  /// Creates a [SelectCategoryEvent].
  ///
  /// Parameters:
  /// - [category]: The scoring category to select.
  SelectCategoryEvent(this.category);
}

/// Event triggered when starting a new game.
///
/// This event resets all game state to initial values, allowing
/// the player to start a fresh game.
///
/// **Behavior:**
/// - Resets score sheet to empty
/// - Creates new round with fresh dice
/// - Sets game state to playing
///
/// Example:
/// ```dart
/// bloc.add(NewGameEvent());
/// ```
class NewGameEvent extends GameEvent {}

/// The [GameBloc] manages the state of a Poker Dice game.
///
/// This BLoC (Business Logic Component) handles all game events and
/// emits state changes for UI updates. It serves as the central
/// hub for game logic and state management.
///
/// **State Transitions:**
/// 1. [GameInitial] → [GamePlaying]: On first dice roll
/// 2. [GamePlaying] → [GamePlaying]: During normal play (rolling, toggling, scoring)
/// 3. [GamePlaying] → [GameOver]: When all 13 categories are scored
/// 4. Any state → [GamePlaying]: On new game event
///
/// **Validation:**
/// - Prevents rolling when max rolls reached
/// - Prevents toggling dice when game is over
/// - Prevents scoring already-scored categories
/// - Validates die indices
///
/// Example:
/// ```dart
/// final bloc = GameBloc();
/// bloc.add(RollDiceEvent());
/// bloc.add(ToggleDieEvent(0));
/// bloc.add(SelectCategoryEvent(ScoreCategory.aces));
/// ```
class GameBloc extends Bloc<GameEvent, GameState> {
  /// Creates a [GameBloc] with initial state [GameInitial].
  ///
  /// Registers event handlers for all game events:
  /// - [RollDiceEvent]: Handled by [onRollDice]
  /// - [ToggleDieEvent]: Handled by [onToggleDie]
  /// - [SelectCategoryEvent]: Handled by [onSelectCategory]
  /// - [NewGameEvent]: Handled by [onNewGame]
  ///
  /// Initial state is [GameInitial] representing a game that hasn't started.
  GameBloc() : super(GameInitial()) {
    on<RollDiceEvent>(onRollDice);
    on<ToggleDieEvent>(onToggleDie);
    on<SelectCategoryEvent>(onSelectCategory);
    on<NewGameEvent>(onNewGame);
  }

  /// Handles [RollDiceEvent] by rolling the dice.
  ///
  /// This method processes the roll dice event with the following logic:
  /// 1. Checks if game is over (no action if true)
  /// 2. Checks if max rolls reached (no action if true)
  /// 3. If in [GameInitial] state, transitions to [GamePlaying]
  /// 4. Otherwise, rolls the dice and emits updated state
  ///
  /// Parameters:
  /// - [event]: The roll dice event (contains no additional data).
  /// - [emit]: The state emitter function.
  ///
  /// State Transitions:
  /// - [GameInitial] → [GamePlaying]: On first roll
  /// - [GamePlaying] → [GamePlaying]: On subsequent rolls
  /// - No change: If game is over or max rolls reached
  ///
  /// Example:
  /// ```dart
  /// // In UI
  /// context.read<GameBloc>().add(RollDiceEvent());
  /// ```
  void onRollDice(RollDiceEvent event, Emitter<GameState> emit) {
    final currentState = state;

    // Cannot roll if game is over
    if (currentState.isGameOver) {
      return;
    }

    // Cannot roll if max rolls reached
    if (!currentState.currentRound.canRoll()) {
      return;
    }

    // Handle GameInitial state - first roll starts the game
    if (currentState is GameInitial) {
      // First roll transitions from GameInitial to GamePlaying
      final updatedRound = currentState.currentRound.rollDice();
      emit(
        GamePlaying(
          currentRound: updatedRound,
          scoreSheet: currentState.scoreSheet,
        ),
      );
      return;
    }

    final updatedState = currentState.rollDice();
    emit(updatedState);
  }

  /// Handles [ToggleDieEvent] by toggling the hold state of a die.
  ///
  /// This method toggles the hold state for the specified die index.
  /// Held dice are not rolled when [RollDiceEvent] is triggered.
  ///
  /// Parameters:
  /// - [event]: The toggle die event containing the die index.
  /// - [emit]: The state emitter function.
  ///
  /// Behavior:
  /// - Toggles hold state of die at [event.index]
  /// - No action if game is over
  /// - Logs and ignores invalid indices
  ///
  /// Example:
  /// ```dart
  /// // Hold first die
  /// context.read<GameBloc>().add(ToggleDieEvent(0));
  /// ```
  void onToggleDie(ToggleDieEvent event, Emitter<GameState> emit) {
    final currentState = state;

    // Cannot toggle if game is over
    if (currentState.isGameOver) {
      return;
    }

    try {
      final updatedState = currentState.toggleDie(event.index);
      emit(updatedState);
    } catch (e) {
      // Invalid index, ignore the event
      log('Invalid die index: ${event.index}', error: e);
    }
  }

  /// Handles [SelectCategoryEvent] by scoring the selected category.
  ///
  /// This method scores the selected category using current dice values,
  /// updates the score sheet, and starts a new round (or ends the game).
  ///
  /// Parameters:
  /// - [event]: The select category event containing the category.
  /// - [emit]: The state emitter function.
  ///
  /// Behavior:
  /// - Validates category is not already scored
  /// - Calculates and stores the score
  /// - Starts new round with fresh dice
  /// - Transitions to [GameOver] if all categories scored
  ///
  /// Throws:
  /// - [StateError]: If category is already scored or invalid
  ///
  /// Example:
  /// ```dart
  /// // Score aces
  /// context.read<GameBloc>().add(SelectCategoryEvent(ScoreCategory.aces));
  /// ```
  void onSelectCategory(SelectCategoryEvent event, Emitter<GameState> emit) {
    final currentState = state;

    // Cannot select category if game is over
    if (currentState.isGameOver) {
      return;
    }

    // Validate that the category is in the list of valid categories
    if (!currentState.getValidCategories().contains(event.category)) {
      throw StateError(
        'Cannot select category ${event.category.displayName}: '
        'category is already scored or invalid.',
      );
    }

    try {
      final updatedState = currentState.selectCategory(event.category);
      emit(updatedState);
    } catch (e) {
      log('Error selecting category: ${event.category}', error: e);
      rethrow;
    }
  }

  /// Handles [NewGameEvent] by resetting the game to initial state.
  ///
  /// This method creates a fresh game with:
  /// - Empty score sheet
  /// - New round with 5 fresh dice
  /// - Game in playing state
  ///
  /// Parameters:
  /// - [event]: The new game event (contains no additional data).
  /// - [emit]: The state emitter function.
  ///
  /// State Transition:
  /// - Any state → [GamePlaying] with fresh game state
  ///
  /// Example:
  /// ```dart
  /// // Start new game
  /// context.read<GameBloc>().add(NewGameEvent());
  /// ```
  void onNewGame(NewGameEvent event, Emitter<GameState> emit) {
    final updatedState = state.newGame();
    emit(updatedState);
  }

  /// Synchronously selects a [category] (for testing purposes).
  ///
  /// This method directly calls the state's [selectCategory] method
  /// and throws any errors synchronously, making it useful for unit tests.
  ///
  /// Parameters:
  /// - [category]: The category to score.
  ///
  /// Returns:
  /// The updated [GameState] after scoring the category.
  ///
  /// Throws:
  /// - [StateError]: If category is already scored
  ///
  /// Example:
  /// ```dart
  /// // In tests
  /// final newState = bloc.selectCategorySync(ScoreCategory.aces);
  /// expect(newState.scoreSheet.isCategoryScored(ScoreCategory.aces), isTrue);
  /// ```
  GameState selectCategorySync(ScoreCategory category) {
    return state.selectCategory(category);
  }
}

/// Represents the initial state of the game before it starts.
///
/// The game is in this state when:
/// - The app first loads
/// - A new game has been started but no dice have been rolled
///
/// **Characteristics:**
/// - Empty score sheet (all categories unscored)
/// - Fresh round with 5 unheld dice
/// - Roll count is 0
/// - Game not over
///
/// **Transition:**
/// - Transitions to [GamePlaying] on first [RollDiceEvent]
///
/// Example:
/// ```dart
/// final bloc = GameBloc();
/// final state = bloc.state; // GameInitial
/// ```
class GameInitial extends GameState {
  /// Creates a [GameInitial] state with empty round and score sheet.
  ///
  /// Initializes with:
  /// - New [GameRound] with 5 fresh unheld dice
  /// - New [ScoreSheet] with no scores
  /// - [isGameOver] set to false
  GameInitial() : super();

  @override
  bool get isGameOver => false;
}

/// Represents the state of an active game in progress.
///
/// The game is in this state during normal play, which includes:
/// - Rolling dice (up to 3 times per round)
/// - Toggling die hold states
/// - Selecting categories to score
///
/// **Characteristics:**
/// - Active round with dice and roll count
/// - Partially filled score sheet
/// - Game not over
///
/// **Transitions:**
/// - From [GameInitial]: On first dice roll
/// - To [GameOver]: When all 13 categories are scored
///
/// Example:
/// ```dart
/// bloc.add(RollDiceEvent()); // Transitions from GameInitial to GamePlaying
/// final state = bloc.state; // GamePlaying
/// ```
class GamePlaying extends GameState {
  /// Creates a [GamePlaying] state.
  ///
  /// Parameters:
  /// - [currentRound]: The current round of play.
  /// - [scoreSheet]: The score sheet with current scores.
  ///
  /// Initializes with [isGameOver] set to false.
  GamePlaying({super.currentRound, super.scoreSheet})
    : super(isGameOver: false);
}

/// Represents the state when the game has ended.
///
/// The game reaches this state when all 13 categories have been scored.
/// At this point:
/// - No more dice rolls are allowed
/// - No more die toggling is allowed
/// - Final score is displayed
/// - Player can start a new game
///
/// **Characteristics:**
/// - Complete score sheet with all 13 categories scored
/// - Grand total calculated including bonus
/// - [isGameOver] set to true
///
/// **Transitions:**
/// - From [GamePlaying]: When last category is scored
/// - To [GamePlaying]: On [NewGameEvent]
///
/// Example:
/// ```dart
/// // After scoring all categories
/// final state = bloc.state; // GameOver
/// print(state.scoreSheet.getTotal()); // Final score
/// ```
class GameOver extends GameState {
  /// Creates a [GameOver] state.
  ///
  /// Parameters:
  /// - [scoreSheet]: The final score sheet with all scores filled.
  ///
  /// Initializes with [isGameOver] set to true.
  GameOver({required super.scoreSheet}) : super(isGameOver: true);
}
