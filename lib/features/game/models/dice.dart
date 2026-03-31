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

  /// Unique identifier for each roll, used to trigger animations.
  /// Incremented on every roll to detect roll events even when value stays the same.
  final int rollId;

  /// Creates a new Dice instance.
  ///
  /// [value] defaults to null (unrolled/blank).
  /// [isHeld] defaults to false.
  /// [rollId] defaults to 0.
  const Dice({this.value, this.isHeld = false, this.rollId = 0});

  /// Returns a new [Dice] instance with a random value (1-6).
  /// Increments rollId to trigger roll animations even if value stays the same.
  Dice roll() {
    return Dice(value: _randomValue(), isHeld: isHeld, rollId: rollId + 1);
  }

  /// Returns a new [Dice] instance with inverted hold state.
  Dice toggleHold() {
    return Dice(value: value, isHeld: !isHeld, rollId: rollId);
  }

  /// Generates a random dice value between 1 and 6.
  int _randomValue() {
    return Random().nextInt(6) + 1;
  }

  /// Creates a copy of this [Dice] with the given fields replaced.
  Dice copyWith({int? value, bool? isHeld, int? rollId}) {
    return Dice(
      value: value ?? this.value,
      isHeld: isHeld ?? this.isHeld,
      rollId: rollId ?? this.rollId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dice &&
        other.value == value &&
        other.isHeld == isHeld &&
        other.rollId == rollId;
  }

  @override
  int get hashCode => value.hashCode ^ isHeld.hashCode ^ rollId.hashCode;

  @override
  String toString() => 'Dice(value: $value, isHeld: $isHeld, rollId: $rollId)';

  /// Serializes this [Dice] to a JSON map.
  ///
  /// Returns a map with 'value', 'isHeld', and 'rollId' keys.
  Map<String, dynamic> toJson() {
    return {'value': value, 'isHeld': isHeld, 'rollId': rollId};
  }

  /// Creates a [Dice] instance from a JSON map.
  ///
  /// [json] should contain 'value' (int?), 'isHeld' (bool), and 'rollId' (int) keys.
  factory Dice.fromJson(Map<String, dynamic> json) {
    return Dice(
      value: json['value'] as int?,
      isHeld: (json['isHeld'] as bool?) ?? false,
      rollId: (json['rollId'] as int?) ?? 0,
    );
  }
}
