/// Game constants for the Poker Dice (Yatzy) game.
///
/// This file defines all core game values including dice faces,
/// game rules, and scoring categories.
library;

/// Card-style dice faces mapped to indices 0-5.
///
/// The dice use card-style values instead of traditional pips:
/// - Index 0: 9
/// - Index 1: 10
/// - Index 2: J (Jack)
/// - Index 3: Q (Queen)
/// - Index 4: K (King)
/// - Index 5: A (Ace)
const List<Object> DICE_FACES = [9, 10, 'J', 'Q', 'K', 'A'];

/// Maximum number of rolls allowed per turn.
const int MAX_ROLLS = 3;

/// Minimum sum required in upper section to earn bonus.
const int BONUS_THRESHOLD = 30;

/// Bonus points awarded when upper section sum meets threshold.
const int BONUS_POINTS = 20;

/// Number of dice used in the game.
const int NUM_DICE = 5;

/// Total number of scoring categories.
///
/// Breakdown:
/// - 6 upper section categories (pairs of each face)
/// - 6 lower section categories (combinations)
/// - 1 bonus category
const int NUM_CATEGORIES = 13;

/// Upper section scoring category names.
///
/// Each category scores the sum of all dice matching the specified face.
const List<String> UPPER_CATEGORIES = [
  'Pair of 9s',
  'Pair of 10s',
  'Pair of Jacks',
  'Pair of Queens',
  'Pair of Kings',
  'Pair of Aces',
];

/// Lower section scoring category names.
///
/// Scoring rules:
/// - Two Pair: Two different pairs (sum of 4 dice)
/// - Three of a Kind: At least 3 same (sum of all)
/// - Four of a Kind: At least 4 same (sum of all)
/// - Straight: 9-10-J-Q-K-A (25 points)
/// - Full House: Three + Pair (sum of all)
/// - Yatzy: All 5 same (50 points)
const List<String> LOWER_CATEGORIES = [
  'Two Pair',
  'Three of a Kind',
  'Four of a Kind',
  'Straight',
  'Full House',
  'Yatzy',
];

/// Bonus category name.
const String BONUS_CATEGORY = 'Bonus';
