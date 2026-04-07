import 'dart:math';

/// Represents a single die in the Poker Dice game.
///
/// A Die has a face value (1-6) and can be held to prevent rolling.
/// This class is immutable - all operations return new instances.
///
/// Example:
/// ```dart
/// var die = Die(value: 3, held: false);
/// die = die.roll(); // Rolls to a new value
/// die = die.toggleHold(); // Toggles held state
/// ```
class Die {
  /// The face value of the die (1-6).
  final int value;

  /// Whether the die is currently held (not rolled).
  ///
  /// When [held] is true, the die will not be rolled when [roll] is called.
  final bool held;

  /// Creates a new [Die] instance.
  ///
  /// The [value] defaults to 1 if not specified.
  /// The [held] state defaults to false if not specified.
  ///
  /// Example:
  /// ```dart
  /// const Die die1 = Die(); // value: 1, held: false
  /// const Die die2 = Die(value: 6, held: true); // value: 6, held: true
  /// ```
  const Die({this.value = 1, this.held = false});

  /// Rolls the die, generating a random value between 1 and 6.
  ///
  /// Returns a new [Die] instance with a randomly generated value.
  /// The [held] state is preserved in the returned instance.
  ///
  /// Note: This method uses [Random] from dart:math for randomness.
  ///
  /// Example:
  /// ```dart
  /// var die = Die(value: 1, held: false);
  /// die = die.roll(); // New value between 1-6, held: false
  /// ```
  ///
  /// Returns:
  /// A new [Die] with a random value (1-6) and the same [held] state.
  Die roll() {
    final randomValue = (Random().nextDouble() * 6).floor() + 1;
    return Die(value: randomValue, held: held);
  }

  /// Toggles the held state of the die.
  ///
  /// Returns a new [Die] instance with the opposite [held] state.
  /// The [value] is preserved in the returned instance.
  ///
  /// Example:
  /// ```dart
  /// var die = Die(value: 3, held: false);
  /// die = die.toggleHold(); // value: 3, held: true
  /// die = die.toggleHold(); // value: 3, held: false
  /// ```
  ///
  /// Returns:
  /// A new [Die] with the same [value] and toggled [held] state.
  Die toggleHold() {
    return Die(value: value, held: !held);
  }

  /// Creates a copy of this [Die] with optional updated properties.
  ///
  /// This method is useful for immutability when modifying die properties.
  /// Only specified parameters are changed; others retain their current values.
  ///
  /// Example:
  /// ```dart
  /// var die = Die(value: 4, held: false);
  /// die = die.copyWith(held: true); // value: 4, held: true
  /// die = die.copyWith(value: 6); // value: 6, held: true
  /// ```
  ///
  /// Parameters:
  /// - [value]: The new face value (defaults to current value if null).
  /// - [held]: The new held state (defaults to current state if null).
  ///
  /// Returns:
  /// A new [Die] instance with the specified properties updated.
  Die copyWith({int? value, bool? held}) {
    return Die(value: value ?? this.value, held: held ?? this.held);
  }
}
