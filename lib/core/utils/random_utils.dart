import 'dart:math';

/// Utility class for random number generation.
///
/// Provides deterministic random generation for testing purposes
/// through optional seeding.
class RandomUtils {
  static final Random _random = Random();

  /// Generates a random dice value (0-5 index for card faces).
  ///
  /// Returns a value between 0 and 5 (inclusive).
  static int nextDiceValue() {
    return _random.nextInt(6);
  }

  /// Generates multiple random dice values.
  ///
  /// [count] - The number of dice values to generate. Must be positive.
  /// Returns a list of values between 0 and 5 (inclusive).
  static List<int> nextDiceValues(int count) {
    if (count <= 0) {
      throw ArgumentError('Count must be positive');
    }

    return List<int>.generate(count, (_) => _random.nextInt(6));
  }

  /// Generates a random integer within the specified range.
  ///
  /// [min] - The minimum value (inclusive).
  /// [max] - The maximum value (inclusive).
  /// Returns a value between [min] and [max] (inclusive).
  static int nextIntInRange(int min, int max) {
    if (min > max) {
      throw ArgumentError('Min must be less than or equal to max');
    }

    return _random.nextInt(max - min + 1) + min;
  }

  /// Generates a random double between 0.0 and 1.0.
  static double nextDouble() {
    return _random.nextDouble();
  }

  /// Creates a new Random instance with a custom seed.
  ///
  /// [seed] - The seed value for deterministic random generation.
  /// Returns a new Random instance with the specified seed.
  static Random createSeededRandom(int seed) {
    return Random(seed);
  }

  /// Generates a random dice value using a custom seeded Random instance.
  ///
  /// [random] - A seeded Random instance for deterministic results.
  /// Returns a value between 0 and 5 (inclusive).
  static int nextDiceValueWithRandom(Random random) {
    return random.nextInt(6);
  }

  /// Generates multiple random dice values using a custom seeded Random instance.
  ///
  /// [count] - The number of dice values to generate. Must be positive.
  /// [random] - A seeded Random instance for deterministic results.
  /// Returns a list of values between 0 and 5 (inclusive).
  static List<int> nextDiceValuesWithRandom(int count, Random random) {
    if (count <= 0) {
      throw ArgumentError('Count must be positive');
    }

    return List<int>.generate(count, (_) => random.nextInt(6));
  }
}
