/// Represents whether a score category belongs to the upper or lower section.
///
/// The Poker Dice game has two sections:
/// - [upper]: Categories Aces through Sixes (scoring based on die face values)
/// - [lower]: Categories like Three of a Kind, Full House, Straights, etc.
enum ScoreSection { upper, lower }

/// Represents all 13 scoring categories in a Poker Dice game.
///
/// Categories are divided into two sections:
///
/// **Upper Section** (6 categories):
/// - [aces]: Sum of all dice showing 1
/// - [twos]: Sum of all dice showing 2
/// - [threes]: Sum of all dice showing 3
/// - [fours]: Sum of all dice showing 4
/// - [fives]: Sum of all dice showing 5
/// - [sixes]: Sum of all dice showing 6
///
/// **Lower Section** (7 categories):
/// - [threeOfKind]: Sum of all dice if 3 or more match
/// - [fourOfKind]: Sum of all dice if 4 or more match
/// - [fullHouse]: 25 points for 3 of one kind + 2 of another
/// - [smallStraight]: 30 points for 4 consecutive values
/// - [largeStraight]: 40 points for 5 consecutive values
/// - [yatzy]: 50 points (plus bonuses) for all 5 dice matching
/// - [chance]: Sum of all dice
///
/// Example:
/// ```dart
/// for (final category in ScoreCategory.values) {
///   print('${category.displayName} - ${category.section}');
/// }
/// ```
enum ScoreCategory {
  // Upper Section (6 categories)
  aces,
  twos,
  threes,
  fours,
  fives,
  sixes,

  // Lower Section (7 categories)
  threeOfKind,
  fourOfKind,
  fullHouse,
  smallStraight,
  largeStraight,
  yatzy,
  chance,
}

/// Extension providing display names and section information for [ScoreCategory].
///
/// This extension adds useful properties to [ScoreCategory] for UI display
/// and game logic.
///
/// Example:
/// ```dart
/// final category = ScoreCategory.yatzy;
/// print(category.displayName); // 'Yatzy'
/// print(category.section); // ScoreSection.lower
/// print(category.index); // 11
/// ```
extension ScoreCategoryExtension on ScoreCategory {
  /// Returns the user-friendly display name for the category.
  ///
  /// Converts enum names to title case for UI presentation.
  ///
  /// Example:
  /// ```dart
  /// ScoreCategory.threeOfKind.displayName // 'Three of a Kind'
  /// ScoreCategory.smallStraight.displayName // 'Small Straight'
  /// ```
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

  /// Returns the section ([ScoreSection.upper] or [ScoreSection.lower])
  /// this category belongs to.
  ///
  /// The upper section contains categories based on specific die values (1-6).
  /// The lower section contains combination-based scoring categories.
  ///
  /// Example:
  /// ```dart
  /// ScoreCategory.aces.section // ScoreSection.upper
  /// ScoreCategory.yatzy.section // ScoreSection.lower
  /// ```
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

  /// Returns the index position of this category (0-12).
  ///
  /// The index corresponds to the order in which categories appear
  /// in [ScoreCategory.values].
  ///
  /// Example:
  /// ```dart
  /// ScoreCategory.aces.index // 0
  /// ScoreCategory.chance.index // 12
  /// ```
  int get index => ScoreCategory.values.indexOf(this);
}

/// Utility class providing helper methods for [ScoreCategory] operations.
///
/// This class contains static methods for categorizing and accessing
/// score categories in the Poker Dice game.
class ScoreCategoryHelper {
  /// Returns all upper section categories.
  ///
  /// The upper section includes categories for scoring specific die values
  /// (Aces through Sixes). These categories award points equal to the sum
  /// of dice showing the specified value.
  ///
  /// Returns:
  /// A list containing [ScoreCategory.aces] through [ScoreCategory.sixes].
  ///
  /// Example:
  /// ```dart
  /// final upper = ScoreCategoryHelper.getUpperCategories();
  /// print(upper.length); // 6
  /// ```
  static List<ScoreCategory> getUpperCategories() {
    return ScoreCategory.values
        .where((category) => category.section == ScoreSection.upper)
        .toList();
  }

  /// Returns all lower section categories.
  ///
  /// The lower section includes combination-based scoring categories
  /// (Three of a Kind through Chance). These categories award points
  /// based on dice combinations.
  ///
  /// Returns:
  /// A list containing [ScoreCategory.threeOfKind] through [ScoreCategory.chance].
  ///
  /// Example:
  /// ```dart
  /// final lower = ScoreCategoryHelper.getLowerCategories();
  /// print(lower.length); // 7
  /// ```
  static List<ScoreCategory> getLowerCategories() {
    return ScoreCategory.values
        .where((category) => category.section == ScoreSection.lower)
        .toList();
  }

  /// Returns the index position of a [category] (0-12).
  ///
  /// This is a convenience method that delegates to the extension property.
  ///
  /// Parameters:
  /// - [category]: The category to get the index for.
  ///
  /// Returns:
  /// The zero-based index position of the category.
  ///
  /// Example:
  /// ```dart
  /// ScoreCategoryHelper.getCategoryIndex(ScoreCategory.fives); // 4
  /// ```
  static int getCategoryIndex(ScoreCategory category) {
    return category.index;
  }
}
