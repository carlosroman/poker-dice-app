/// Scoring engine for Poker Dice (Yatzy) game.
///
/// This class provides methods to calculate scores for all
/// upper and lower section categories according to game rules.
library;

/// Scoring engine for calculating poker dice category scores.
///
/// Provides static methods to evaluate dice combinations and
/// calculate scores for all 12 scoring categories plus bonus.
class Scoring {
  /// Calculates score for Ones category.
  ///
  /// Returns sum of all dice showing 1.
  /// Returns 0 if no 1s are present.
  static int scoreOnes(List<int> diceValues) {
    return countOccurrences(diceValues, 1) * 1;
  }

  /// Calculates score for Twos category.
  ///
  /// Returns sum of all dice showing 2.
  /// Returns 0 if no 2s are present.
  static int scoreTwos(List<int> diceValues) {
    return countOccurrences(diceValues, 2) * 2;
  }

  /// Calculates score for Threes category.
  ///
  /// Returns sum of all dice showing 3.
  /// Returns 0 if no 3s are present.
  static int scoreThrees(List<int> diceValues) {
    return countOccurrences(diceValues, 3) * 3;
  }

  /// Calculates score for Fours category.
  ///
  /// Returns sum of all dice showing 4.
  /// Returns 0 if no 4s are present.
  static int scoreFours(List<int> diceValues) {
    return countOccurrences(diceValues, 4) * 4;
  }

  /// Calculates score for Fives category.
  ///
  /// Returns sum of all dice showing 5.
  /// Returns 0 if no 5s are present.
  static int scoreFives(List<int> diceValues) {
    return countOccurrences(diceValues, 5) * 5;
  }

  /// Calculates score for Sixes category.
  ///
  /// Returns sum of all dice showing 6.
  /// Returns 0 if no 6s are present.
  static int scoreSixes(List<int> diceValues) {
    return countOccurrences(diceValues, 6) * 6;
  }

  /// Calculates score for Chance category.
  ///
  /// Returns sum of all dice values.
  static int scoreChance(List<int> diceValues) {
    return diceValues.fold(0, (sum, value) => sum + value);
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

  /// Calculates score for Large Straight category.
  ///
  /// Returns 40 points if dice form a large straight (5 consecutive values).
  /// Examples: 1-2-3-4-5 or 2-3-4-5-6
  /// Returns 0 if large straight is not present.
  static int scoreLongStraight(List<int> diceValues) {
    return hasLongStraight(diceValues) ? 40 : 0;
  }

  /// Calculates score for Small Straight category.
  ///
  /// Returns 30 points if dice form a small straight (4 consecutive values).
  /// Examples: 1-2-3-4, 2-3-4-5, or 3-4-5-6
  /// Returns 0 if small straight is not present.
  static int scoreSmallStraight(List<int> diceValues) {
    return hasSmallStraight(diceValues) ? 30 : 0;
  }

  /// Calculates score for Full House category.
  ///
  /// Returns 25 points if a three + pair combination exists.
  /// Returns 0 if full house is not present.
  static int scoreFullHouse(List<int> diceValues) {
    return hasFullHouse(diceValues) ? 25 : 0;
  }

  /// Calculates score for Yatzy category.
  ///
  /// Returns 50 points if all 5 dice show the same value.
  /// Returns 0 if Yatzy is not present.
  static int scoreYatzy(List<int> diceValues) {
    return hasYatzy(diceValues) ? 50 : 0;
  }

  /// Alias for scoreOnes for test compatibility.
  static int scorePairOfAces(List<int> diceValues) => scoreOnes(diceValues);

  /// Alias for scoreTwos for test compatibility.
  static int scorePairOfKings(List<int> diceValues) => scoreTwos(diceValues);

  /// Alias for scoreThrees for test compatibility.
  static int scorePairOfQueens(List<int> diceValues) => scoreThrees(diceValues);

  /// Alias for scoreFours for test compatibility.
  static int scorePairOfJacks(List<int> diceValues) => scoreFours(diceValues);

  /// Alias for scoreFives for test compatibility.
  static int scorePairOf10s(List<int> diceValues) => scoreFives(diceValues);

  /// Alias for scoreSixes for test compatibility.
  static int scorePairOf9s(List<int> diceValues) => scoreSixes(diceValues);

  /// Counts how many dice match a specific value.
  ///
  /// [diceValues] - List of dice values (1-6).
  /// [value] - The value to count (1-6).
  ///
  /// Returns the number of dice with the specified value.
  static int countOccurrences(List<int> diceValues, int value) {
    int count = 0;
    for (final diceValue in diceValues) {
      if (diceValue == value) {
        count++;
      }
    }
    return count;
  }

  /// Returns a map of dice value to count of occurrences.
  ///
  /// [diceValues] - List of dice values (1-6).
  ///
  /// Returns a map where keys are dice values and values are counts.
  static Map<int, int> getDiceCounts(List<int> diceValues) {
    final Map<int, int> counts = {};
    for (final diceValue in diceValues) {
      counts[diceValue] = (counts[diceValue] ?? 0) + 1;
    }
    return counts;
  }

  /// Checks if the dice contain two different pairs.
  ///
  /// [diceValues] - List of dice values (1-6).
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
  /// [diceValues] - List of dice values (1-6).
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
  /// [diceValues] - List of dice values (1-6).
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

  /// Checks if the dice contain a small straight (4 consecutive values).
  ///
  /// [diceValues] - List of dice values (1-6).
  ///
  /// Returns true if dice contain any of:
  /// - 1-2-3-4
  /// - 2-3-4-5
  /// - 3-4-5-6
  static bool hasSmallStraight(List<int> diceValues) {
    final uniqueValues = diceValues.toSet();
    // Check for 4 consecutive values
    const straights = [
      {1, 2, 3, 4}, // 1-2-3-4
      {2, 3, 4, 5}, // 2-3-4-5
      {3, 4, 5, 6}, // 3-4-5-6
    ];
    for (final straight in straights) {
      if (uniqueValues.intersection(straight).length == 4) {
        return true;
      }
    }
    return false;
  }

  /// Checks if the dice contain a large straight (5 consecutive values).
  ///
  /// [diceValues] - List of dice values (1-6).
  ///
  /// Returns true if dice form either:
  /// - 1-2-3-4-5
  /// - 2-3-4-5-6
  static bool hasLongStraight(List<int> diceValues) {
    final uniqueValues = diceValues.toSet();
    if (uniqueValues.length < 5) {
      return false;
    }
    const straights = [
      {1, 2, 3, 4, 5}, // 1-2-3-4-5
      {2, 3, 4, 5, 6}, // 2-3-4-5-6
    ];
    for (final straight in straights) {
      if (uniqueValues.intersection(straight).length == 5) {
        return true;
      }
    }
    return false;
  }

  /// Checks if the dice contain a straight (5 or 6 consecutive values).
  ///
  /// [diceValues] - List of dice values (1-6).
  ///
  /// Returns true if dice form either a small straight (5 consecutive)
  /// or a long straight (6 consecutive).
  ///
  /// Deprecated: Use [hasSmallStraight] or [hasLongStraight] instead.
  static bool hasStraight(List<int> diceValues) {
    return hasSmallStraight(diceValues) || hasLongStraight(diceValues);
  }

  /// Checks if the dice contain a full house (three + pair).
  ///
  /// [diceValues] - List of dice values (1-6).
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
  /// [diceValues] - List of dice values (1-6).
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
