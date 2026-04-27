/// Represents the 14 scoring categories in Yatzy, plus a bonus category.
///
/// Categories are organized into two sections:
/// - Upper Section: Sum of specific dice values (ones through sixes)
/// - Lower Section: Pattern-based scoring (three of a kind, straights, etc.)
enum Category {
  /// Upper Section Categories
  ones,
  twos,
  threes,
  fours,
  fives,
  sixes,

  /// Lower Section Categories
  threeOfAKind,
  fourOfAKind,
  fullHouse,
  smallStraight,
  largeStraight,
  yatzy,
  chance,

  /// Bonus category for upper section bonus (+35 when sum >= 63)
  bonus,
}

/// Extension on Category to provide additional functionality
extension CategoryExtension on Category {
  /// Returns the display name for UI purposes.
  ///
  /// Upper Section: "Ones", "Twos", "Threes", "Fours", "Fives", "Sixes"
  /// Lower Section: "Three of a Kind", "Four of a Kind", "Full House", etc.
  /// Bonus: "Bonus"
  String get displayName {
    switch (this) {
      case Category.ones:
        return 'Ones';
      case Category.twos:
        return 'Twos';
      case Category.threes:
        return 'Threes';
      case Category.fours:
        return 'Fours';
      case Category.fives:
        return 'Fives';
      case Category.sixes:
        return 'Sixes';
      case Category.threeOfAKind:
        return 'Three of a Kind';
      case Category.fourOfAKind:
        return 'Four of a Kind';
      case Category.fullHouse:
        return 'Full House';
      case Category.smallStraight:
        return 'Small Straight';
      case Category.largeStraight:
        return 'Large Straight';
      case Category.yatzy:
        return 'Yatzy';
      case Category.chance:
        return 'Chance';
      case Category.bonus:
        return 'Bonus';
    }
  }

  /// Returns true if this category belongs to the Upper Section.
  ///
  /// Upper Section categories are: ones, twos, threes, fours, fives, sixes, bonus
  bool get isUpperSection {
    switch (this) {
      case Category.ones:
      case Category.twos:
      case Category.threes:
      case Category.fours:
      case Category.fives:
      case Category.sixes:
      case Category.bonus:
        return true;
      case Category.threeOfAKind:
      case Category.fourOfAKind:
      case Category.fullHouse:
      case Category.smallStraight:
      case Category.largeStraight:
      case Category.yatzy:
      case Category.chance:
        return false;
    }
  }

  /// Returns the index of this category for ordering in the scorecard.
  ///
  /// Upper Section: 0-5 (ones through sixes), 13 (bonus)
  /// Lower Section: 6-12 (threeOfAKind through chance)
  int get index {
    switch (this) {
      case Category.ones:
        return 0;
      case Category.twos:
        return 1;
      case Category.threes:
        return 2;
      case Category.fours:
        return 3;
      case Category.fives:
        return 4;
      case Category.sixes:
        return 5;
      case Category.threeOfAKind:
        return 6;
      case Category.fourOfAKind:
        return 7;
      case Category.fullHouse:
        return 8;
      case Category.smallStraight:
        return 9;
      case Category.largeStraight:
        return 10;
      case Category.yatzy:
        return 11;
      case Category.chance:
        return 12;
      case Category.bonus:
        return 13;
    }
  }
}
