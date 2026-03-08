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

/// Minor section scoring category names.
///
/// Scoring rules (count of matching dice × multiplier):
/// - 9s: count × 1 (1 each)
/// - 10s: count × 2 (2 each)
/// - Js: count × 3 (3 each)
/// - Qs: count × 4 (4 each)
/// - Ks: count × 5 (5 each)
/// - As: count × 6 (6 each)
const List<String> UPPER_CATEGORIES = ['9s', '10s', 'Js', 'Qs', 'Ks', 'As'];

/// Major section scoring category names.
///
/// Scoring rules:
/// - Three of a Kind: sum of all dice
/// - Four of a Kind: sum of all dice
/// - Full House: 25 points
/// - Straight: 40 points
/// - Flush: sum of all dice
/// - Five of a Kind: 50 points
const List<String> LOWER_CATEGORIES = [
  'Three of a Kind',
  'Four of a Kind',
  'Full House',
  'Straight',
  'Flush',
  'Five of a Kind',
];

/// Bonus category name.
const String BONUS_CATEGORY = 'Bonus';
