/// Represents a single die in the poker dice game.
///
/// A die has a [value] between 0 and 6 and can be held ([isHeld]).
/// A value of 0 represents a blank (unrolled) die.
class Dice {
  /// The face value of the die (0-6).
  /// A value of 0 represents a blank (unrolled) die.
  final int value;

  /// Whether the die is held and should not be re-rolled.
  final bool isHeld;

  /// Creates a [Dice] with the given [value] and [isHeld] state.
  ///
  /// Throws an [AssertionError] if [value] is not between 0 and 6.
  const Dice({required this.value, this.isHeld = false})
    : assert(value >= 0 && value <= 6, 'Dice value must be between 0 and 6');

  /// Creates a copy of this die with the given fields replaced.
  Dice copyWith({int? value, bool? isHeld}) {
    return Dice(value: value ?? this.value, isHeld: isHeld ?? this.isHeld);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dice && other.value == value && other.isHeld == isHeld;
  }

  @override
  int get hashCode => Object.hash(value, isHeld);

  @override
  String toString() => 'Dice(value: $value, isHeld: $isHeld)';
}
