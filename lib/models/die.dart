import 'dart:math' show Random;

/// Represents a single die in the poker dice game.
///
/// A die has a value between 1 and 6 and can be held to prevent
/// it from being rolled again.
class Die {
  static final _random = Random();

  /// The face value of the die (1-6).
  final int value;

  /// Whether the die is held/fixed and won't be rolled.
  final bool isHeld;

  /// Creates a new Die with the specified [value] and [isHeld] state.
  ///
  /// The [value] must be between 1 and 6 (inclusive).
  /// The [isHeld] parameter defaults to [false].
  Die({required this.value, this.isHeld = false})
    : assert(value >= 1 && value <= 6, 'Value must be between 1 and 6');

  /// Creates a new random die with a random value between 1 and 6.
  ///
  /// The die is not held by default.
  factory Die.random() {
    return Die(value: _randomInt(1, 6));
  }

  /// Generates a random integer between [min] and [max] (inclusive).
  static int _randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  /// Returns a new [Die] instance with the held state toggled.
  ///
  /// The value remains unchanged.
  Die toggleHeld() {
    return Die(value: value, isHeld: !isHeld);
  }

  /// Returns a new [Die] instance with a new random value.
  ///
  /// The held state remains unchanged.
  Die roll() {
    if (isHeld) {
      return this;
    }
    return Die(value: _randomInt(1, 6), isHeld: isHeld);
  }

  /// Returns a new [Die] instance with the specified [value] and/or [isHeld].
  ///
  /// This follows the copyWith pattern for immutability.
  Die copyWith({int? value, bool? isHeld}) {
    return Die(value: value ?? this.value, isHeld: isHeld ?? this.isHeld);
  }

  @override
  String toString() {
    return 'Die(value: $value, isHeld: $isHeld)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Die && other.value == value && other.isHeld == isHeld;
  }

  @override
  int get hashCode => value.hashCode ^ isHeld.hashCode;
}
