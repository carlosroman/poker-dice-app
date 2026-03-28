/// Game constants for the Poker Dice (Yatzy) game.
///
/// This file defines all core game values including dice faces,
/// game rules, and scoring categories.
library;

/// Traditional dice faces with values 1-6.
///
/// The dice use traditional pip values:
/// - 1: Single center pip
/// - 2: Two pips (diagonal)
/// - 3: Three pips (diagonal)
/// - 4: Four pips (corners)
/// - 5: Five pips (corners + center)
/// - 6: Six pips (two columns of 3)
const List<int> DICE_FACES = [1, 2, 3, 4, 5, 6];

/// Maximum number of rolls allowed per turn.
const int MAX_ROLLS = 3;

/// Minimum sum required in upper section to earn bonus.
const int BONUS_THRESHOLD = 20;

/// Bonus points awarded when upper section sum meets threshold.
const int BONUS_POINTS = 50;

/// Number of dice used in the game.
const int NUM_DICE = 5;

/// Total number of scoring categories.
///
/// Breakdown:
/// - 6 upper section categories (Ones through Sixes)
/// - 7 lower section categories (combinations + Chance)
/// - 1 bonus category
const int NUM_CATEGORIES = 14;

/// Upper section scoring category names.
///
/// Scoring rules: sum of all dice matching the category value.
/// - Ones: sum of all 1s
/// - Twos: sum of all 2s
/// - Threes: sum of all 3s
/// - Fours: sum of all 4s
/// - Fives: sum of all 5s
/// - Sixes: sum of all 6s
const List<String> UPPER_CATEGORIES = [
  'Ones',
  'Twos',
  'Threes',
  'Fours',
  'Fives',
  'Sixes',
];

/// Lower section scoring category names.
///
/// Scoring rules:
/// - Three of a Kind: sum of all dice
/// - Four of a Kind: sum of all dice
/// - Full House: 25 points
/// - Sm. Straight: 30 points (5 consecutive: 1-2-3-4-5 or 2-3-4-5-6)
/// - Lg. Straight: 40 points (6 consecutive: 1-2-3-4-5-6)
/// - Yahtzee: 50 points (5 same)
/// - Chance: sum of all dice
const List<String> LOWER_CATEGORIES = [
  'Three of a Kind',
  'Four of a Kind',
  'Full House',
  'Sm. Straight',
  'Lg. Straight',
  'Yahtzee',
  'Chance',
];

/// Bonus category name.
const String BONUS_CATEGORY = 'Bonus';
