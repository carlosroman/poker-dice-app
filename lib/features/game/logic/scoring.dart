/// Scoring engine for Poker Dice game.
///
/// This class provides methods to calculate scores for all
/// upper and lower section categories according to game rules.
library;

/// Scoring engine for calculating poker dice category scores.
///
/// Provides static methods to evaluate dice combinations and
/// calculate scores for all 12 scoring categories plus bonus.
class Scoring {
  /// Calculates score for Pair of 9s category.
  ///
  /// Returns sum of all dice showing 9 (value index 0).
  /// Returns 0 if no 9s are present.
  static int scorePairOf9s(List<int> diceValues) {
    return countOccurrences(diceValues, 0) * 9;
  }

  /// Calculates score for Pair of 10s category.
  ///
  /// Returns sum of all dice showing 10 (value index 1).
  /// Returns 0 if no 10s are present.
  static int scorePairOf10s(List<int> diceValues) {
    return countOccurrences(diceValues, 1) * 10;
  }

  /// Calculates score for Pair of Jacks category.
  ///
  /// Returns sum of all dice showing Jack (value index 2).
  /// Returns 0 if no Jacks are present.
  static int scorePairOfJacks(List<int> diceValues) {
    return countOccurrences(diceValues, 2) * 11;
  }

  /// Calculates score for Pair of Queens category.
  ///
  /// Returns sum of all dice showing Queen (value index 3).
  /// Returns 0 if no Queens are present.
  static int scorePairOfQueens(List<int> diceValues) {
    return countOccurrences(diceValues, 3) * 12;
  }

  /// Calculates score for Pair of Kings category.
  ///
  /// Returns sum of all dice showing King (value index 4).
  /// Returns 0 if no Kings are present.
  static int scorePairOfKings(List<int> diceValues) {
    return countOccurrences(diceValues, 4) * 13;
  }

  /// Calculates score for Pair of Aces category.
  ///
  /// Returns sum of all dice showing Ace (value index 5).
  /// Returns 0 if no Aces are present.
  static int scorePairOfAces(List<int> diceValues) {
    return countOccurrences(diceValues, 5) * 14;
  }

  /// Calculates score for Two Pair category.
  ///
  /// Returns sum of the 4 dice forming two different pairs.
  /// Returns 0 if two pairs are not present.
  static int scoreTwoPair(List<int> diceValues) {
    if (!hasTwoPair(diceValues)) {
      return 0;
    }

    final Map<int, int> counts = getDiceCounts(diceValues);
    int sum = 0;
    int pairsFound = 0;

    for (final entry in counts.entries) {
      if (entry.value == 2 && pairsFound < 2) {
        sum += entry.key * 2;
        pairsFound++;
      }
    }

    return sum;
  }

  /// Calculates score for Three of a Kind category.
  ///
  /// Returns sum of all dice if at least 3 match.
  /// Returns 0 if three of a kind is not present.
  static int scoreThreeOfAKind(List<int> diceValues) {
    if (!hasThreeOfAKind(diceValues)) {
      return 0;
    }

    return diceValues.fold(0, (sum, value) => sum + value);
  }

  /// Calculates score for Four of a Kind category.
  ///
  /// Returns sum of all dice if at least 4 match.
  /// Returns 0 if four of a kind is not present.
  static int scoreFourOfAKind(List<int> diceValues) {
    if (!hasFourOfAKind(diceValues)) {
      return 0;
    }

    return diceValues.fold(0, (sum, value) => sum + value);
  }

  /// Calculates score for Straight category.
  ///
  /// Returns 25 points if all 6 unique values are present (9-10-J-Q-K-A).
  /// Returns 0 if straight is not present.
  static int scoreStraight(List<int> diceValues) {
    return hasStraight(diceValues) ? 25 : 0;
  }

  /// Calculates score for Full House category.
  ///
  /// Returns sum of all dice if a three + pair combination exists.
  /// Returns 0 if full house is not present.
  static int scoreFullHouse(List<int> diceValues) {
    if (!hasFullHouse(diceValues)) {
      return 0;
    }

    return diceValues.fold(0, (sum, value) => sum + value);
  }

  /// Calculates score for Yatzy category.
  ///
  /// Returns 50 points if all 5 dice show the same value.
  /// Returns 0 if yatzy is not present.
  static int scoreYatzy(List<int> diceValues) {
    return hasYatzy(diceValues) ? 50 : 0;
  }

  /// Counts how many dice match a specific value index.
  ///
  /// [diceValues] - List of value indices (0-5) representing dice faces.
  /// [valueIndex] - The index to count (0=9, 1=10, 2=J, 3=Q, 4=K, 5=A).
  ///
  /// Returns the number of dice with the specified value index.
  static int countOccurrences(List<int> diceValues, int valueIndex) {
    int count = 0;
    for (final value in diceValues) {
      if (value == valueIndex) {
        count++;
      }
    }
    return count;
  }

  /// Returns a map of value index to count of occurrences.
  ///
  /// [diceValues] - List of value indices (0-5) representing dice faces.
  ///
  /// Returns a map where keys are value indices and values are counts.
  static Map<int, int> getDiceCounts(List<int> diceValues) {
    final Map<int, int> counts = {};

    for (final value in diceValues) {
      counts[value] = (counts[value] ?? 0) + 1;
    }

    return counts;
  }

  /// Checks if the dice contain two different pairs.
  ///
  /// [diceValues] - List of value indices (0-5) representing dice faces.
  ///
  /// Returns true if there are exactly two different values that each appear twice.
  static bool hasTwoPair(List<int> diceValues) {
    final Map<int, int> counts = getDiceCounts(diceValues);
    int pairs = 0;

    for (final count in counts.values) {
      if (count == 2) {
        pairs++;
      }
    }

    return pairs == 2;
  }

  /// Checks if the dice contain at least three of the same value.
  ///
  /// [diceValues] - List of value indices (0-5) representing dice faces.
  ///
  /// Returns true if any value appears 3 or more times.
  static bool hasThreeOfAKind(List<int> diceValues) {
    final Map<int, int> counts = getDiceCounts(diceValues);

    for (final count in counts.values) {
      if (count >= 3) {
        return true;
      }
    }

    return false;
  }

  /// Checks if the dice contain at least four of the same value.
  ///
  /// [diceValues] - List of value indices (0-5) representing dice faces.
  ///
  /// Returns true if any value appears 4 or more times.
  static bool hasFourOfAKind(List<int> diceValues) {
    final Map<int, int> counts = getDiceCounts(diceValues);

    for (final count in counts.values) {
      if (count >= 4) {
        return true;
      }
    }

    return false;
  }

  /// Checks if the dice contain a straight (all 6 unique values).
  ///
  /// [diceValues] - List of value indices (0-5) representing dice faces.
  ///
  /// Returns true if all 6 dice show different values (9-10-J-Q-K-A).
  static bool hasStraight(List<int> diceValues) {
    return diceValues.toSet().length == 6;
  }

  /// Checks if the dice contain a full house (three + pair).
  ///
  /// [diceValues] - List of value indices (0-5) representing dice faces.
  ///
  /// Returns true if there is one value appearing 3 times and another appearing 2 times.
  static bool hasFullHouse(List<int> diceValues) {
    final Map<int, int> counts = getDiceCounts(diceValues);
    bool hasThree = false;
    bool hasTwo = false;

    for (final count in counts.values) {
      if (count == 3) {
        hasThree = true;
      } else if (count == 2) {
        hasTwo = true;
      }
    }

    return hasThree && hasTwo;
  }

  /// Checks if all 5 dice show the same value.
  ///
  /// [diceValues] - List of value indices (0-5) representing dice faces.
  ///
  /// Returns true if all dice match (Yatzy).
  static bool hasYatzy(List<int> diceValues) {
    final Map<int, int> counts = getDiceCounts(diceValues);

    for (final count in counts.values) {
      if (count == 5) {
        return true;
      }
    }

    return false;
  }
}
