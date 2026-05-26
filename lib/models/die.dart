import 'dart:math';

/// Represents a single die in a poker dice game.
class Die {
  static final _random = Random();

  final int value;
  final bool isHeld;

  Die({int? value, this.isHeld = false})
    : value = _validate(value ?? _random.nextInt(6) + 1);

  static int _validate(int value) {
    if (value < 1 || value > 6) {
      throw ArgumentError.value(value, 'value', 'Must be between 1 and 6');
    }
    return value;
  }

  /// Returns a new [Die] with the [isHeld] state flipped.
  Die toggleHold() {
    return copyWith(isHeld: !isHeld);
  }

  /// Returns a new [Die] with the specified fields replaced.
  Die copyWith({int? value, bool? isHeld}) {
    return Die(value: value ?? this.value, isHeld: isHeld ?? this.isHeld);
  }

  @override
  String toString() => 'Die(value: $value, isHeld: $isHeld)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Die && other.value == value && other.isHeld == isHeld;
  }

  @override
  int get hashCode => Object.hash(value, isHeld);
}
