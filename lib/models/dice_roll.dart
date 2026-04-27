import 'die.dart';

/// Represents a roll of 5 dice in the poker dice game.
///
/// This class provides functionality for managing dice rolls, including
/// sorting, counting occurrences, and rolling unheld dice.
class DiceRoll {
  /// The list of exactly 5 dice in this roll.
  final List<Die> dice;

  /// Creates a [DiceRoll] with the specified [dice].
  ///
  /// The [dice] list must contain exactly 5 elements.
  DiceRoll(this.dice)
    : assert(dice.length == 5, 'DiceRoll must contain exactly 5 dice');

  /// Creates a [DiceRoll] with 5 random dice.
  ///
  /// Each die has a random value between 1 and 6, and none are held by default.
  factory DiceRoll.random() {
    return DiceRoll(List<Die>.generate(5, (_) => Die.random()));
  }

  /// Creates a [DiceRoll] from a list of specific values.
  ///
  /// This is useful for testing. The [values] list must contain exactly 5 elements.
  /// All dice are created with [isHeld] set to false.
  factory DiceRoll.fromValues(List<int> values) {
    assert(values.length == 5, 'Values list must contain exactly 5 elements');
    return DiceRoll(
      List<Die>.generate(5, (index) => Die(value: values[index])),
    );
  }

  /// Returns a getter that returns dice sorted by value in ascending order.
  List<Die> get sortedDice {
    final List<Die> sorted = List<Die>.from(dice);
    sorted.sort((a, b) => a.value.compareTo(b.value));
    return sorted;
  }

  /// Returns how many dice show the given [value].
  ///
  /// The [value] should be between 1 and 6.
  /// Returns 0 if no dice show the specified value.
  int countOccurrences(int value) {
    int count = 0;
    for (final Die die in dice) {
      if (die.value == value) {
        count++;
      }
    }
    return count;
  }

  /// Returns a map of value -> count for all dice.
  ///
  /// The map keys are die values (1-6) and values are the count of dice showing that value.
  /// Only values that appear in the dice are included in the map.
  Map<int, int> getDiceCounts() {
    final Map<int, int> counts = <int, int>{};
    for (final Die die in dice) {
      counts[die.value] = (counts[die.value] ?? 0) + 1;
    }
    return counts;
  }

  /// Returns the sum of all dice values.
  int sumAllDice() {
    int sum = 0;
    for (final Die die in dice) {
      sum += die.value;
    }
    return sum;
  }

  /// Toggles the held state of the die at the specified [index].
  ///
  /// Returns a new [DiceRoll] instance with the updated held state.
  /// The [index] must be between 0 and 4 (inclusive).
  DiceRoll toggleDieHeld(int index) {
    assert(index >= 0 && index < 5, 'Index must be between 0 and 4');
    final List<Die> newDice = List<Die>.from(dice);
    newDice[index] = dice[index].toggleHeld();
    return DiceRoll(newDice);
  }

  /// Rolls all dice that are not held.
  ///
  /// Returns a new [DiceRoll] instance with the updated dice values.
  /// Held dice remain unchanged.
  DiceRoll rollUnheldDice() {
    final List<Die> newDice = List<Die>.generate(
      5,
      (index) => dice[index].roll(),
    );
    return DiceRoll(newDice);
  }

  /// Returns true if all dice are held.
  bool get allHeld {
    for (final Die die in dice) {
      if (!die.isHeld) {
        return false;
      }
    }
    return true;
  }

  /// Returns a new [DiceRoll] instance with the specified [dice] or original dice.
  ///
  /// This follows the copyWith pattern for immutability.
  DiceRoll copyWith({List<Die>? dice}) {
    return DiceRoll(dice ?? this.dice);
  }

  @override
  String toString() {
    return 'DiceRoll(dice: $dice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DiceRoll) return false;
    if (dice.length != other.dice.length) return false;
    for (int i = 0; i < dice.length; i++) {
      if (dice[i] != other.dice[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    int hash = 0;
    for (final Die die in dice) {
      hash = hash * 31 + die.hashCode;
    }
    return hash;
  }
}
