import 'die.dart';

/// Represents a single round of play in the Poker Dice game.
///
/// A [GameRound] manages the state of exactly 5 dice and tracks the number
/// of rolls performed during the round. Each player gets up to 3 rolls per
/// round to achieve the best possible combination.
///
/// **Features:**
/// - Manages 5 dice with individual hold states
/// - Tracks roll count (0-3 rolls allowed per round)
/// - All operations return new instances for immutability
/// - Supports toggling die hold state
///
/// **Game Flow:**
/// 1. Start with 5 fresh dice (rollCount = 0)
/// 2. Roll dice up to 3 times
/// 3. Hold desired dice between rolls
/// 4. Select a category to score after final roll
///
/// Example:
/// ```dart
/// var round = GameRound(); // 5 fresh dice, 0 rolls
/// round = round.rollDice(); // First roll, rollCount = 1
/// round = round.toggleDie(0); // Hold first die
/// round = round.rollDice(); // Second roll (only unheld dice), rollCount = 2
/// ```
class GameRound {
  /// The list of exactly 5 dice in this round.
  ///
  /// Each die has a face value (1-6) and a hold state.
  /// Held dice are not rolled when [rollDice] is called.
  final List<Die> dice;

  /// The number of rolls performed in this round (0-3).
  ///
  /// Players can roll up to 3 times per round.
  /// When [rollCount] reaches 3, no more rolls are allowed.
  final int rollCount;

  /// Creates a new [GameRound] instance.
  ///
  /// Parameters:
  /// - [dice]: Optional list of dice. Defaults to 5 new unheld dice if not provided.
  /// - [rollCount]: Initial roll count. Defaults to 0.
  ///
  /// Throws:
  /// - [ArgumentError]: If [dice] list does not contain exactly 5 elements.
  ///
  /// Example:
  /// ```dart
  /// final round1 = GameRound(); // 5 fresh dice, rollCount: 0
  /// final round2 = GameRound(rollCount: 1); // Starting with 1 roll already made
  /// ```
  GameRound({List<Die>? dice, this.rollCount = 0})
    : dice =
          dice ?? List<Die>.unmodifiable(List.generate(5, (_) => const Die())) {
    if (this.dice.length != 5) {
      throw ArgumentError('Dice list must contain exactly 5 elements');
    }
  }

  /// Rolls the unheld dice (or all dice if no indices provided).
  ///
  /// Rolls all dice that are not held, generating new random values.
  /// Held dice retain their current values.
  ///
  /// Parameters:
  /// - [keptIndices]: Optional list of die indices to keep (not roll).
  ///   If provided, only dice NOT in this list will be rolled.
  ///   If not provided, all dice that are not held will be rolled.
  ///
  /// Returns:
  /// A new [GameRound] instance with updated dice and incremented [rollCount].
  /// Returns the same instance if [rollCount] >= 3 (no more rolls allowed).
  ///
  /// Example:
  /// ```dart
  /// var round = GameRound();
  /// round = round.rollDice(); // First roll, rollCount = 1
  /// round = round.toggleDie(0); // Hold die at index 0
  /// round = round.rollDice(); // Rolls dice 1-4, keeps die 0, rollCount = 2
  /// ```
  GameRound rollDice([List<int>? keptIndices]) {
    if (!canRoll()) {
      return this;
    }

    final List<int> indicesToKeep = keptIndices ?? getHeldIndices();
    final List<Die> newDice = List<Die>.generate(5, (index) {
      final die = dice[index];
      // Keep the die if it's in the keptIndices list or if it's held
      if (indicesToKeep.contains(index) || die.held) {
        return die;
      }
      // Roll the die
      return die.roll();
    });

    return GameRound(dice: newDice, rollCount: rollCount + 1);
  }

  /// Toggles the held state of the die at the given [index].
  ///
  /// Holding a die prevents it from being rolled in subsequent rolls.
  /// Players typically hold dice that contribute to desired combinations.
  ///
  /// Parameters:
  /// - [index]: The index of the die to toggle (0-4).
  ///
  /// Returns:
  /// A new [GameRound] instance with the updated dice list.
  ///
  /// Throws:
  /// - [ArgumentError]: If [index] is out of bounds (< 0 or >= 5).
  ///
  /// Example:
  /// ```dart
  /// var round = GameRound();
  /// round = round.toggleDie(0); // Hold die at index 0
  /// round = round.toggleDie(0); // Unhold die at index 0
  /// ```
  GameRound toggleDie(int index) {
    if (index < 0 || index >= 5) {
      throw ArgumentError('Index must be between 0 and 4, got: $index');
    }

    final List<Die> newDice = List<Die>.from(dice);
    newDice[index] = dice[index].copyWith(held: !dice[index].held);

    return GameRound(dice: newDice, rollCount: rollCount);
  }

  /// Returns true if more rolls are available ([rollCount] < 3).
  ///
  /// Players are allowed up to 3 rolls per round.
  ///
  /// Returns:
  /// True if the player can roll again, false if max rolls reached.
  ///
  /// Example:
  /// ```dart
  /// final round = GameRound(rollCount: 2);
  /// round.canRoll(); // true (1 roll remaining)
  /// ```
  bool canRoll() {
    return rollCount < 3;
  }

  /// Returns a list of indices of currently held dice.
  ///
  /// Returns:
  /// A list of integer indices (0-4) for dice where [held] is true.
  ///
  /// Example:
  /// ```dart
  /// final round = GameRound();
  /// round.toggleDie(0);
  /// round.toggleDie(2);
  /// round.getHeldIndices(); // [0, 2]
  /// ```
  List<int> getHeldIndices() {
    return List<int>.generate(
      dice.length,
      (index) => index,
    ).where((index) => dice[index].held).toList();
  }

  /// Creates a copy of this [GameRound] with optional updated values.
  ///
  /// Parameters:
  /// - [dice]: New dice list (defaults to current dice if null).
  /// - [rollCount]: New roll count (defaults to current count if null).
  ///
  /// Returns:
  /// A new [GameRound] instance with the specified properties updated.
  ///
  /// Example:
  /// ```dart
  /// final copy = round.copyWith(rollCount: 3);
  /// ```
  GameRound copyWith({List<Die>? dice, int? rollCount}) {
    return GameRound(
      dice: dice ?? this.dice,
      rollCount: rollCount ?? this.rollCount,
    );
  }
}
