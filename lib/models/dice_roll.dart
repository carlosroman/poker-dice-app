import 'package:poker_dice/models/die.dart';

/// Represents a roll of 5 dice in a poker dice game.
class DiceRoll {
  static const int _diceCount = 5;

  final List<Die> dice;

  DiceRoll({List<Die>? dice})
    : dice = dice != null && dice.length == _diceCount
          ? List<Die>.unmodifiable(dice)
          : List<Die>.unmodifiable(
              List<Die>.generate(_diceCount, (_) => Die()),
            );

  /// Returns a new list of dice sorted by value (ascending).
  List<Die> get sortedDice {
    final sorted = List<Die>.from(dice);
    sorted.sort((a, b) => a.value.compareTo(b.value));
    return sorted;
  }

  /// Returns the count of dice showing [value].
  int countOccurrences(int value) {
    return dice.where((die) => die.value == value).length;
  }

  /// Returns the list of all die values in order.
  List<int> getValues() {
    return dice.map((die) => die.value).toList();
  }

  /// Returns the indices of dice that are currently held.
  List<int> getHeldIndices() {
    final indices = <int>[];
    for (var i = 0; i < dice.length; i++) {
      if (dice[i].isHeld) {
        indices.add(i);
      }
    }
    return indices;
  }

  /// Returns a new [DiceRoll] where only unheld dice are re-rolled.
  DiceRoll rollUnheld() {
    final newDice = <Die>[];
    for (final die in dice) {
      if (die.isHeld) {
        newDice.add(die);
      } else {
        newDice.add(Die());
      }
    }
    return DiceRoll(dice: newDice);
  }

  /// Returns a new [DiceRoll] with the specified fields replaced.
  DiceRoll copyWith({List<Die>? dice}) {
    return DiceRoll(dice: dice ?? this.dice);
  }

  @override
  String toString() => 'DiceRoll(dice: $dice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiceRoll &&
        dice.length == other.dice.length &&
        Iterable.generate(dice.length).every((i) => dice[i] == other.dice[i]);
  }

  @override
  int get hashCode => Object.hashAll(dice);
}
