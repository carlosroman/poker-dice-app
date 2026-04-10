/// Represents the section of the scorecard (Minor or Major).
enum ScoreSection {
  /// Minor section: Individual die values (1-6)
  minor,

  /// Major section: Combination categories
  major,
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
        return '1';
      case ScoreCategory.twos:
        return '2';
      case ScoreCategory.threes:
        return '3';
      case ScoreCategory.fours:
        return '4';
      case ScoreCategory.fives:
        return '5';
      case ScoreCategory.sixes:
        return '6';
      case ScoreCategory.threeOfKind:
        return '3x';
      case ScoreCategory.fourOfKind:
        return '4x';
      case ScoreCategory.fullHouse:
        return 'House';
      case ScoreCategory.smallStraight:
        return 'small';
      case ScoreCategory.largeStraight:
        return 'large';
      case ScoreCategory.yatzy:
        return 'Yatzy';
      case ScoreCategory.chance:
        return '?';
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
        return ScoreSection.minor;
      case ScoreCategory.threeOfKind:
      case ScoreCategory.fourOfKind:
      case ScoreCategory.fullHouse:
      case ScoreCategory.smallStraight:
      case ScoreCategory.largeStraight:
      case ScoreCategory.yatzy:
      case ScoreCategory.chance:
        return ScoreSection.major;
    }
  }

  /// Returns true if this category belongs to the Minor section.
  bool get isMinor => section == ScoreSection.minor;

  /// Returns true if this category belongs to the Major section.
  bool get isMajor => section == ScoreSection.major;
}
