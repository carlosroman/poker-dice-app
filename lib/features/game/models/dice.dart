import 'dart:math';

/// Represents a single traditional dice in the game.
///
/// This immutable data class manages the state of a dice,
/// including its current value (1-6) and whether it is held between rolls.
class Dice {
  /// The dice value (1-6 for traditional dice faces).
  /// Null means the dice has not been rolled yet.
  final int? value;

  /// Whether the dice is held between rolls.
  final bool isHeld;

  /// Creates a new Dice instance.
  ///
  /// [value] defaults to null (unrolled/blank).
  /// [isHeld] defaults to false.
  const Dice({this.value, this.isHeld = false});

  /// Returns a new [Dice] instance with a random value (1-6).
  Dice roll() {
    return Dice(value: _randomValue(), isHeld: isHeld);
  }

  /// Returns a new [Dice] instance with inverted hold state.
  Dice toggleHold() {
    return Dice(value: value, isHeld: !isHeld);
  }

  /// Generates a random dice value between 1 and 6.
  int _randomValue() {
    return Random().nextInt(6) + 1;
  }

  /// Creates a copy of this [Dice] with the given fields replaced.
  Dice copyWith({int? value, bool? isHeld}) {
    return Dice(value: value ?? this.value, isHeld: isHeld ?? this.isHeld);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dice && other.value == value && other.isHeld == isHeld;
  }

  @override
  int get hashCode => value.hashCode ^ isHeld.hashCode;

  @override
  String toString() => 'Dice(value: $value, isHeld: $isHeld)';

  /// Serializes this [Dice] to a JSON map.
  ///
  /// Returns a map with 'value' and 'isHeld' keys.
  Map<String, dynamic> toJson() {
    return {'value': value, 'isHeld': isHeld};
  }

  /// Creates a [Dice] instance from a JSON map.
  ///
  /// [json] should contain 'value' (int?) and 'isHeld' (bool) keys.
  factory Dice.fromJson(Map<String, dynamic> json) {
    return Dice(
      value: json['value'] as int?,
      isHeld: (json['isHeld'] as bool?) ?? false,
    );
  }
}
