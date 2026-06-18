/// Service responsible for rolling dice in the poker dice game.
///
/// Supports seeded random number generation for deterministic testing.
library;

import 'dart:math';

import 'package:poker_dice/models/dice.dart';

/// Rolls five dice with values between 1 and 6.
///
/// An optional [seed] can be provided for deterministic results (useful in tests).
class DiceRoller {
  /// The random number generator instance.
  final Random _random;

  /// Creates a [DiceRoller] with an optional [seed] for reproducible results.
  DiceRoller({int? seed}) : _random = seed != null ? Random(seed) : Random();

  /// Rolls 5 dice, each with a random value between 1 and 6.
  ///
  /// All returned dice have [Dice.isHeld] set to `false`.
  List<Dice> rollDice() {
    return List<Dice>.generate(5, (_) => Dice(value: _random.nextInt(6) + 1));
  }
}
