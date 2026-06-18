import 'package:flutter/material.dart';

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
