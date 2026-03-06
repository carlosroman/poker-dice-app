import 'dart:math';

import '../../../core/constants/dice_faces.dart';

/// Represents a single poker dice in the game.
///
/// This immutable data class manages the state of a dice,
/// including its current value and whether it is held between rolls.
class Dice {
  /// The dice value as an index (0-5) mapping to card faces:
  /// 0=9, 1=10, 2=J, 3=Q, 4=K, 5=A
  /// Null means the dice has not been rolled yet.
  final int? value;

  /// Whether the dice is held between rolls.
  final bool isHeld;

  /// Creates a new Dice instance.
  ///
  /// [value] defaults to null (unrolled/blank).
  /// [isHeld] defaults to false.
  const Dice({this.value, this.isHeld = false});

  /// Returns a new [Dice] instance with a random value (0-5).
  Dice roll() {
    return Dice(value: _randomValue(), isHeld: isHeld);
  }

  /// Returns a new [Dice] instance with inverted hold state.
  Dice toggleHold() {
    return Dice(value: value, isHeld: !isHeld);
  }

  /// Returns the actual card face value based on the value index.
  ///
  /// Returns: 9, 10, 'J', 'Q', 'K', or 'A', or null if unrolled.
  Object? getFaceValue() {
    return value != null ? DICE_FACES[value!] : null;
  }

  /// Generates a random dice value between 0 and 5.
  int _randomValue() {
    return Random().nextInt(6);
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
}
