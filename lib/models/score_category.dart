import 'package:flutter/material.dart';
import 'package:poker_dice/models/dice.dart';

/// Defines all scoring categories in the poker dice game.
///
/// Categories are split into upper (aces through sixes) and lower
/// (three of a kind through chance) sections.
enum ScoreCategory {
  /// Sum of all dice showing 1.
  aces,

  /// Sum of all dice showing 2.
  twos,

  /// Sum of all dice showing 3.
  threes,

  /// Sum of all dice showing 4.
  fours,

  /// Sum of all dice showing 5.
  fives,

  /// Sum of all dice showing 6.
  sixes,

  /// Three dice of the same value.
  threeOfAKind,

  /// Four dice of the same value.
  fourOfAKind,

  /// Three of one value and two of another.
  fullHouse,

  /// Four consecutive values.
  smallStraight,

  /// Five consecutive values.
  largeStraight,

  /// All five dice show the same value.
  yatzy,

  /// Sum of all dice regardless of value.
  chance,
}

/// Extension providing display and scoring helpers for [ScoreCategory].
extension ScoreCategoryX on ScoreCategory {
  /// Whether this category belongs to the upper section (aces – sixes).
  bool get isUpper {
    return this == ScoreCategory.aces ||
        this == ScoreCategory.twos ||
        this == ScoreCategory.threes ||
        this == ScoreCategory.fours ||
        this == ScoreCategory.fives ||
        this == ScoreCategory.sixes;
  }

  /// Human-readable display name for the category.
  String get displayName {
    switch (this) {
      case ScoreCategory.aces:
        return 'Aces';
      case ScoreCategory.twos:
        return 'Twos';
      case ScoreCategory.threes:
        return 'Threes';
      case ScoreCategory.fours:
        return 'Fours';
      case ScoreCategory.fives:
        return 'Fives';
      case ScoreCategory.sixes:
        return 'Sixes';
      case ScoreCategory.threeOfAKind:
        return 'Three of a Kind';
      case ScoreCategory.fourOfAKind:
        return 'Four of a Kind';
      case ScoreCategory.fullHouse:
        return 'Full House';
      case ScoreCategory.smallStraight:
        return 'Small Straight';
      case ScoreCategory.largeStraight:
        return 'Large Straight';
      case ScoreCategory.yatzy:
        return 'Yatzy';
      case ScoreCategory.chance:
        return 'Chance';
    }
  }

  /// Icon data appropriate for the category display.
  IconData get icon {
    switch (this) {
      case ScoreCategory.aces:
        return Icons.looks_one;
      case ScoreCategory.twos:
        return Icons.looks_two;
      case ScoreCategory.threes:
        return Icons.looks_3;
      case ScoreCategory.fours:
        return Icons.looks_4;
      case ScoreCategory.fives:
        return Icons.looks_5;
      case ScoreCategory.sixes:
        return Icons.looks_6;
      case ScoreCategory.threeOfAKind:
        return Icons.format_list_numbered;
      case ScoreCategory.fourOfAKind:
        return Icons.star;
      case ScoreCategory.fullHouse:
        return Icons.home;
      case ScoreCategory.smallStraight:
        return Icons.trending_up;
      case ScoreCategory.largeStraight:
        return Icons.trending_up;
      case ScoreCategory.yatzy:
        return Icons.emoji_events;
      case ScoreCategory.chance:
        return Icons.casino;
    }
  }

  /// Calculates the score for this category based on the given dice.
  /// Returns 0 if the category cannot be scored with the current dice.
  int calculateScore(List<Dice> dice) {
    switch (this) {
      // Upper section: sum of dice matching the face value
      case ScoreCategory.aces:
      case ScoreCategory.twos:
      case ScoreCategory.threes:
      case ScoreCategory.fours:
      case ScoreCategory.fives:
      case ScoreCategory.sixes:
        int sum = 0;
        for (final die in dice) {
          if (die.value == diceValue) {
            sum += die.value;
          }
        }
        return sum;

      // Three of a kind: sum of all dice if any value appears 3+ times
      case ScoreCategory.threeOfAKind:
        if (_hasCount(dice, 3)) {
          int sum = 0;
          for (final die in dice) {
            sum += die.value;
          }
          return sum;
        }
        return 0;

      // Four of a kind: sum of all dice if any value appears 4+ times
      case ScoreCategory.fourOfAKind:
        if (_hasCount(dice, 4)) {
          int sum = 0;
          for (final die in dice) {
            sum += die.value;
          }
          return sum;
        }
        return 0;

      // Full house: 25 points if three of one value and two of another
      case ScoreCategory.fullHouse:
        if (_isFullHouse(dice)) {
          return 25;
        }
        return 0;

      // Small straight: 30 points for 4 consecutive values
      case ScoreCategory.smallStraight:
        if (_isSmallStraight(dice)) {
          return 30;
        }
        return 0;

      // Large straight: 40 points for 5 consecutive values
      case ScoreCategory.largeStraight:
        if (_isLargeStraight(dice)) {
          return 40;
        }
        return 0;

      // Yatzy: 50 points if all dice show the same value
      case ScoreCategory.yatzy:
        if (_hasCount(dice, 5)) {
          return 50;
        }
        return 0;

      // Chance: sum of all dice
      case ScoreCategory.chance:
        int sum = 0;
        for (final die in dice) {
          sum += die.value;
        }
        return sum;
    }
  }

  bool _hasCount(List<Dice> dice, int count) {
    for (int v = 1; v <= 6; v++) {
      int c = 0;
      for (final die in dice) {
        if (die.value == v) c++;
      }
      if (c >= count) return true;
    }
    return false;
  }

  bool _isFullHouse(List<Dice> dice) {
    int threeCount = 0;
    int twoCount = 0;
    for (int v = 1; v <= 6; v++) {
      int c = 0;
      for (final die in dice) {
        if (die.value == v) c++;
      }
      if (c == 3) threeCount++;
      if (c == 2) twoCount++;
    }
    return threeCount == 1 && twoCount == 1;
  }

  bool _isSmallStraight(List<Dice> dice) {
    final values = <int>{};
    for (final die in dice) {
      if (die.value > 0) values.add(die.value);
    }
    final sorted = values.toList()..sort();
    int consecutive = 1;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] == sorted[i - 1] + 1) {
        consecutive++;
        if (consecutive >= 4) return true;
      } else {
        consecutive = 1;
      }
    }
    return false;
  }

  bool _isLargeStraight(List<Dice> dice) {
    final values = <int>{};
    for (final die in dice) {
      if (die.value > 0) values.add(die.value);
    }
    return (values.contains(1) &&
            values.contains(2) &&
            values.contains(3) &&
            values.contains(4) &&
            values.contains(5)) ||
        (values.contains(2) &&
            values.contains(3) &&
            values.contains(4) &&
            values.contains(5) &&
            values.contains(6));
  }

  /// The die face value (1-6) for upper categories, null otherwise.
  int? get diceValue {
    switch (this) {
      case ScoreCategory.aces:
        return 1;
      case ScoreCategory.twos:
        return 2;
      case ScoreCategory.threes:
        return 3;
      case ScoreCategory.fours:
        return 4;
      case ScoreCategory.fives:
        return 5;
      case ScoreCategory.sixes:
        return 6;
      default:
        return null;
    }
  }

  /// Deterministic ordering index used for UI sorting.
  int get categoryOrder {
    switch (this) {
      case ScoreCategory.aces:
        return 0;
      case ScoreCategory.twos:
        return 1;
      case ScoreCategory.threes:
        return 2;
      case ScoreCategory.fours:
        return 3;
      case ScoreCategory.fives:
        return 4;
      case ScoreCategory.sixes:
        return 5;
      case ScoreCategory.threeOfAKind:
        return 6;
      case ScoreCategory.fourOfAKind:
        return 7;
      case ScoreCategory.fullHouse:
        return 8;
      case ScoreCategory.smallStraight:
        return 9;
      case ScoreCategory.largeStraight:
        return 10;
      case ScoreCategory.yatzy:
        return 11;
      case ScoreCategory.chance:
        return 12;
    }
  }
}
