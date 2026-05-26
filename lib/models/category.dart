/// Scoring categories for a poker dice game.
enum Category {
  // Upper section
  ones('Ones'),
  twos('Twos'),
  threes('Threes'),
  fours('Fours'),
  fives('Fives'),
  sixes('Sixes'),

  // Lower section
  threeOfAKind('Three of a Kind'),
  fourOfAKind('Four of a Kind'),
  fullHouse('Full House'),
  smallStraight('Small Straight'),
  largeStraight('Large Straight'),
  yatzy('Yatzy'),
  house('House'),
  chance('Chance');

  const Category(this.displayName);

  /// Human-readable name for UI display.
  final String displayName;

  /// Whether this category belongs to the upper section.
  bool get isUpperSection =>
      this == ones ||
      this == twos ||
      this == threes ||
      this == fours ||
      this == fives ||
      this == sixes;

  /// Returns all upper section categories.
  static List<Category> getUpperCategories() {
    return [ones, twos, threes, fours, fives, sixes];
  }

  /// Returns all lower section categories.
  static List<Category> getLowerCategories() {
    return [
      threeOfAKind,
      fourOfAKind,
      fullHouse,
      smallStraight,
      largeStraight,
      yatzy,
      house,
      chance,
    ];
  }
}
