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
  /// Calculates score for As category.
  ///
  /// Returns count of Aces (value index 5) multiplied by 6.
  /// Returns 0 if no Aces are present.
  static int scoreAs(List<int> diceValues) {
    return countOccurrences(diceValues, 5) * 6;
  }

  /// Calculates score for Ks category.
  ///
  /// Returns count of Kings (value index 4) multiplied by 5.
  /// Returns 0 if no Kings are present.
  static int scoreKs(List<int> diceValues) {
    return countOccurrences(diceValues, 4) * 5;
  }

  /// Calculates score for Qs category.
  ///
  /// Returns count of Queens (value index 3) multiplied by 4.
  /// Returns 0 if no Queens are present.
  static int scoreQs(List<int> diceValues) {
    return countOccurrences(diceValues, 3) * 4;
  }

  /// Calculates score for Js category.
  ///
  /// Returns count of Jacks (value index 2) multiplied by 3.
  /// Returns 0 if no Jacks are present.
  static int scoreJs(List<int> diceValues) {
    return countOccurrences(diceValues, 2) * 3;
  }

  /// Calculates score for 10s category.
  ///
  /// Returns count of 10s (value index 1) multiplied by 2.
  /// Returns 0 if no 10s are present.
  static int score10s(List<int> diceValues) {
    return countOccurrences(diceValues, 1) * 2;
  }

  /// Calculates score for 9s category.
  ///
  /// Returns count of 9s (value index 0) multiplied by 1.
  /// Returns 0 if no 9s are present.
  static int score9s(List<int> diceValues) {
    return countOccurrences(diceValues, 0) * 1;
  }

  /// Calculates score for Chance category.
  ///
  /// Returns sum of all dice values. 9 = 1 pt, 10 = 2pt, etc.
  static int scoreChance(List<int> diceValues) {
    // + 1 as 0 = 9pt so must score as 1, 1 = 10 so must score as 2pt
    return diceValues.fold(0, (sum, value) => sum + value + 1);
  }

  /// Calculates score for Three of a Kind category.
  ///
  /// Returns sum of all dice if at least 3 match.
  /// Returns 0 if three of a kind is not present.
  static int scoreThreeOfAKind(List<int> diceValues) {
    if (!hasThreeOfAKind(diceValues)) {
      return 0;
    }
    return diceValues.fold(0, (sum, value) => sum + value + 1);
  }

  /// Calculates score for Four of a Kind category.
  ///
  /// Returns sum of all dice if at least 4 match.
  /// Returns 0 if four of a kind is not present.
  static int scoreFourOfAKind(List<int> diceValues) {
    if (!hasFourOfAKind(diceValues)) {
      return 0;
    }
    return diceValues.fold(0, (sum, value) => sum + value + 1);
  }

  /// Calculates score for Long Straight category.
  ///
  /// Returns 40 points if dice form a long straight (5 consecutive values).
  /// Small Long Straight: 9-10-J-Q-K (indices 0-4)
  /// Large Long Straight: 10-J-Q-K-A (indices 1-5)
  /// Returns 0 if long straight is not present.
  static int scoreLongStraight(List<int> diceValues) {
    return hasLongStraight(diceValues) ? 40 : 0;
  }

  /// Calculates score for Small Straight category.
  ///
  /// Returns 30 points if dice form a small straight (4 consecutive values).
  /// Examples: 9-10-J-Q (0-1-2-3), 10-J-Q-K (1-2-3-4), J-Q-K-A (2-3-4-5)
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
  /// Returns 0 if yatzy is not present.
  static int scoreYatzy(List<int> diceValues) {
    return hasYatzy(diceValues) ? 50 : 0;
  }

  /// Alias for scoreAs for test compatibility.
  static int scorePairOfAces(List<int> diceValues) => scoreAs(diceValues);

  /// Alias for scoreKs for test compatibility.
  static int scorePairOfKings(List<int> diceValues) => scoreKs(diceValues);

  /// Alias for scoreQs for test compatibility.
  static int scorePairOfQueens(List<int> diceValues) => scoreQs(diceValues);

  /// Alias for scoreJs for test compatibility.
  static int scorePairOfJacks(List<int> diceValues) => scoreJs(diceValues);

  /// Alias for score10s for test compatibility.
  static int scorePairOf10s(List<int> diceValues) => score10s(diceValues);

  /// Alias for score9s for test compatibility.
  static int scorePairOf9s(List<int> diceValues) => score9s(diceValues);

  /// Calculates score for Two Pair category.
  ///
  /// Returns sum of the 4 dice forming the two pairs.
  /// Returns 0 if two pairs are not present.
  static int scoreTwoPair(List<int> diceValues) {
    if (!hasTwoPair(diceValues)) {
      return 0;
    }
    final counts = getDiceCounts(diceValues);
    int sum = 0;
    int pairCount = 0;
    for (final entry in counts.entries) {
      if (entry.value == 2) {
        sum += entry.key * 2;
        pairCount++;
      }
    }
    return pairCount == 2 ? sum : 0;
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

  /// Checks if the dice contain a small straight (4 consecutive values).
  ///
  /// [diceValues] - List of value indices (0-5) representing dice faces.
  ///
  /// Returns true if dice contain any 4 consecutive values:
  /// - 9-10-J-Q (indices 0-1-2-3)
  /// - 10-J-Q-K (indices 1-2-3-4)
  /// - J-Q-K-A (indices 2-3-4-5)
  static bool hasSmallStraight(List<int> diceValues) {
    final uniqueValues = diceValues.toSet();
    // Check for 4 consecutive values starting at each possible index
    const straights = [
      {0, 1, 2, 3}, // 9-10-J-Q
      {1, 2, 3, 4}, // 10-J-Q-K
      {2, 3, 4, 5}, // J-Q-K-A
    ];
    for (final straight in straights) {
      if (uniqueValues.intersection(straight).length == 4) {
        return true;
      }
    }
    return false;
  }

  /// Checks if the dice contain a long straight (5 consecutive values).
  ///
  /// [diceValues] - List of value indices (0-5) representing dice faces.
  ///
  /// Returns true if dice form either:
  /// - Small Long Straight: 9-10-J-Q-K (indices 0-4)
  /// - Large Long Straight: 10-J-Q-K-A (indices 1-5)
  static bool hasLongStraight(List<int> diceValues) {
    final uniqueValues = diceValues.toSet();
    if (uniqueValues.length != 5) {
      return false;
    }
    const smallLongStraight = {0, 1, 2, 3, 4};
    if (uniqueValues.intersection(smallLongStraight).length == 5) {
      return true;
    }
    const largeLongStraight = {1, 2, 3, 4, 5};
    if (uniqueValues.intersection(largeLongStraight).length == 5) {
      return true;
    }
    return false;
  }

  /// Checks if the dice contain a straight (5 consecutive values).
  ///
  /// [diceValues] - List of value indices (0-5) representing dice faces.
  ///
  /// Returns true if dice form either:
  /// - Small Straight: 9-10-J-Q-K (indices 0-4)
  /// - Large Straight: 10-J-Q-K-A (indices 1-5)
  ///
  /// Deprecated: Use [hasLongStraight] instead.
  static bool hasStraight(List<int> diceValues) {
    return hasLongStraight(diceValues);
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
