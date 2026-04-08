import 'dart:math';

/// Represents a single poker die with value and held state.
class Die {
  /// The current value of the die (1-6).
  final int value;

  /// Whether the die is currently held.
  final bool held;

  /// Creates a new Die instance.
  ///
  /// [value] defaults to 1 if not specified.
  /// [held] defaults to false if not specified.
  const Die({this.value = 1, this.held = false});

  /// Creates a copy of this die with optional new values.
  Die copyWith({int? value, bool? held}) {
    return Die(value: value ?? this.value, held: held ?? this.held);
  }

  /// Rolls the die to a random value between 1 and 6.
  ///
  /// Returns a new [Die] instance with the rolled value.
  /// The held state is preserved unless explicitly changed.
  Die roll() {
    final rolledValue = (Random().nextInt(6) + 1);
    return copyWith(value: rolledValue);
  }

  /// Toggles the held state of the die.
  ///
  /// Returns a new [Die] instance with the toggled held state.
  /// The value is preserved.
  Die toggleHold() {
    return copyWith(held: !held);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Die && other.value == value && other.held == held;
  }

  @override
  int get hashCode => value.hashCode ^ held.hashCode;

  @override
  String toString() => 'Die(value: $value, held: $held)';
}
