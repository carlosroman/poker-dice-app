/// Represents the section of the scorecard (Upper or Lower).
enum ScoreSection {
  /// Upper section: Aces through Sixes
  upper,

  /// Lower section: ThreeOfKind through Chance
  lower,
}

/// Represents a scoring category in the poker dice game.
///
/// Each category has a display name for UI purposes and belongs to either
/// the Upper or Lower section of the scorecard.
enum ScoreCategory {
  /// Aces (Upper section)
  aces,

  /// Twos (Upper section)
  twos,

  /// Threes (Upper section)
  threes,

  /// Fours (Upper section)
  fours,

  /// Fives (Upper section)
  fives,

  /// Sixes (Upper section)
  sixes,

  /// Three of a Kind (Lower section)
  threeOfKind,

  /// Four of a Kind (Lower section)
  fourOfKind,

  /// Full House (Lower section)
  fullHouse,

  /// Small Straight (Lower section)
  smallStraight,

  /// Large Straight (Lower section)
  largeStraight,

  /// Yatzy (Lower section)
  yatzy,

  /// Chance (Lower section)
  chance;

  /// Returns the display name for UI purposes.
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
      case ScoreCategory.threeOfKind:
        return 'Three of a Kind';
      case ScoreCategory.fourOfKind:
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

  /// Returns the section this category belongs to.
  ScoreSection get section {
    switch (this) {
      case ScoreCategory.aces:
      case ScoreCategory.twos:
      case ScoreCategory.threes:
      case ScoreCategory.fours:
      case ScoreCategory.fives:
      case ScoreCategory.sixes:
        return ScoreSection.upper;
      case ScoreCategory.threeOfKind:
      case ScoreCategory.fourOfKind:
      case ScoreCategory.fullHouse:
      case ScoreCategory.smallStraight:
      case ScoreCategory.largeStraight:
      case ScoreCategory.yatzy:
      case ScoreCategory.chance:
        return ScoreSection.lower;
    }
  }

  /// Returns true if this category belongs to the Upper section.
  bool get isUpper => section == ScoreSection.upper;

  /// Returns true if this category belongs to the Lower section.
  bool get isLower => section == ScoreSection.lower;
}
