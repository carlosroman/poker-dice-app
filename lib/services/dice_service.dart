import 'dart:math';

/// Service for rolling dice.
///
/// Provides random dice roll functionality for the poker dice game.
class DiceService {
  /// Creates a new dice service.
  const DiceService();

  /// Rolls the given number of dice.
  ///
  /// Returns a list of random integers between 1 and 6.
  List<int> rollDice(int count) {
    final random = Random();
    return List.generate(count, (_) => random.nextInt(6) + 1);
  }
}
