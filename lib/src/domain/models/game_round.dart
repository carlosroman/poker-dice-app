import 'die.dart';

/// Represents a single game round in poker dice.
///
/// Manages the state of 5 dice, roll count, and held dice state.
class GameRound {
  /// The maximum number of rolls allowed per round.
  static const int maxRolls = 3;

  /// The number of dice in a round.
  static const int diceCount = 5;

  /// The current dice values and held states.
  final List<Die> dice;

  /// The current roll count (0-3).
  final int rollCount;

  /// Creates a new GameRound instance.
  ///
  /// [dice] defaults to 5 new dice if not specified.
  /// [rollCount] defaults to 0 if not specified.
  GameRound({List<Die>? dice, this.rollCount = 0})
    : dice = dice ?? List.filled(diceCount, const Die());

  /// Creates a copy of this GameRound with optional new values.
  GameRound copyWith({List<Die>? dice, int? rollCount}) {
    return GameRound(
      dice: dice ?? List.from(this.dice),
      rollCount: rollCount ?? this.rollCount,
    );
  }

  /// Rolls the unheld dice and increments roll count.
  ///
  /// [keptIndices] are the indices of dice to keep (not roll).
  /// Returns a new [GameRound] instance with updated dice and roll count.
  ///
  /// Throws [StateError] if rollCount has reached maxRolls.
  GameRound rollDice({List<int>? keptIndices}) {
    if (!canRoll()) {
      throw StateError('Cannot roll: maximum rolls ($maxRolls) reached');
    }

    final indicesToKeep = keptIndices?.toSet() ?? const {};
    final newDice = <Die>[];
    for (var i = 0; i < dice.length; i++) {
      if (indicesToKeep.contains(i)) {
        newDice.add(dice[i]);
      } else {
        newDice.add(dice[i].roll());
      }
    }

    return copyWith(dice: newDice, rollCount: rollCount + 1);
  }

  /// Toggles the held state of the die at the given index.
  ///
  /// [index] is the index of the die to toggle (0-4).
  /// Returns a new [GameRound] instance with updated die state.
  ///
  /// Throws [RangeError] if index is out of bounds.
  GameRound toggleDie(int index) {
    if (index < 0 || index >= dice.length) {
      throw RangeError('Die index $index is out of bounds');
    }

    final newDice = List<Die>.from(dice);
    newDice[index] = dice[index].toggleHold();

    return copyWith(dice: newDice);
  }

  /// Returns true if more rolls are available.
  ///
  /// Returns false when rollCount has reached maxRolls.
  bool canRoll() => rollCount < maxRolls;

  /// Returns the list of held dice.
  List<Die> getHeldDice() => dice.where((die) => die.held).toList();

  /// Returns the list of unheld dice.
  List<Die> getUnheldDice() => dice.where((die) => !die.held).toList();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameRound) return false;

    final diceEqual =
        dice.length == other.dice.length &&
        dice.asMap().entries.every(
          (entry) => entry.value == other.dice[entry.key],
        );

    return diceEqual && rollCount == other.rollCount;
  }

  @override
  int get hashCode => Object.hash(
    dice.fold(0, (hash, die) => Object.hash(hash, die.hashCode)),
    rollCount,
  );

  @override
  String toString() {
    return 'GameRound(dice: $dice, rollCount: $rollCount)';
  }
}
