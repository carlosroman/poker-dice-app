import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/dice_roll.dart';
import '../widgets/header_bar.dart';
import '../widgets/dice_container.dart';
import '../widgets/scorecard.dart';
import '../widgets/bonus_indicator.dart';
import '../widgets/control_bar.dart';

/// The main game screen for the Poker Dice game.
///
/// This screen displays the complete game interface with three sections:
/// 1. **Top Section:** Header with total score
/// 2. **Middle Section:** Dice container, scorecard, and bonus indicator (scrollable)
/// 3. **Bottom Section:** Control bar with Roll and Play buttons
///
/// Example usage:
/// ```dart
/// GameScreen(
///   totalScore: 150,
///   remainingRolls: 2,
///   scores: {Category.ones: 3, Category.twos: 4},
///   selectedCategory: Category.threes,
///   diceRoll: currentDiceRoll,
///   bonusAwarded: false,
///   upperSectionScore: 18,
///   onRollPressed: () => rollDice(),
///   onPlayPressed: () => playSelectedCategory(),
///   onCategoryTapped: (category) => selectCategory(category),
///   onDieToggled: (index) => toggleDieHeld(index),
/// )
/// ```
class GameScreen extends StatelessWidget {
  /// The player's total score across all categories.
  final int totalScore;

  /// Number of rolls remaining in the current turn (0-3).
  final int remainingRolls;

  /// Map of scored categories to their scores.
  ///
  /// Categories not in this map have not been scored yet.
  final Map<Category, int> scores;

  /// The currently selected category for scoring.
  ///
  /// If null, no category is currently selected.
  final Category? selectedCategory;

  /// The current dice roll to display.
  ///
  /// If null, placeholder dice are shown.
  final DiceRoll? diceRoll;

  /// Whether the bonus has been awarded in the upper section.
  final bool bonusAwarded;

  /// The current sum of upper section categories (before bonus).
  final int upperSectionScore;

  /// Callback invoked when the Roll button is pressed.
  final VoidCallback onRollPressed;

  /// Callback invoked when the Play button is pressed.
  final VoidCallback onPlayPressed;

  /// Callback invoked when a category row is tapped.
  final Function(Category category) onCategoryTapped;

  /// Callback invoked when a die is toggled (held/unheld).
  final Function(int index) onDieToggled;

  /// Creates a [GameScreen] widget.
  const GameScreen({
    super.key,
    required this.totalScore,
    required this.remainingRolls,
    required this.scores,
    this.selectedCategory,
    this.diceRoll,
    this.bonusAwarded = false,
    required this.upperSectionScore,
    required this.onRollPressed,
    required this.onPlayPressed,
    required this.onCategoryTapped,
    required this.onDieToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top Section: Header
            _buildHeaderSection(context),

            // Middle Section: Scrollable content
            Expanded(child: _buildMiddleSection(context)),

            // Bottom Section: Control Bar
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  /// Builds the app bar for the screen.
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Poker Dice'),
      centerTitle: true,
      elevation: 2,
    );
  }

  /// Builds the top section with the header.
  Widget _buildHeaderSection(BuildContext context) {
    return HeaderBar(
      totalScore: totalScore,
      playerName: 'Player 1',
      onBackPressed: () => Navigator.maybePop(context),
    );
  }

  /// Builds the middle section with dice, scorecard, and bonus indicator.
  Widget _buildMiddleSection(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: <Widget>[
          // Dice Container
          _buildDiceContainer(context),

          const SizedBox(height: 16),

          // Bonus Indicator
          _buildBonusIndicator(context),

          const SizedBox(height: 16),

          // Scorecard
          _buildScorecard(context),
        ],
      ),
    );
  }

  /// Builds the dice container widget.
  Widget _buildDiceContainer(BuildContext context) {
    return DiceContainer(
      diceRoll: diceRoll,
      onDieToggled: onDieToggled,
      dieSize: MediaQuery.of(context).size.width > 600 ? 80.0 : 60.0,
    );
  }

  /// Builds the bonus indicator widget.
  Widget _buildBonusIndicator(BuildContext context) {
    return BonusIndicator(
      currentScore: upperSectionScore,
      bonusAwarded: bonusAwarded,
      targetScore: 63,
      bonusPoints: 35,
    );
  }

  /// Builds the scorecard widget.
  Widget _buildScorecard(BuildContext context) {
    return Scorecard(
      scores: scores,
      selectedCategory: selectedCategory,
      onCategoryTapped: onCategoryTapped,
    );
  }

  /// Builds the bottom section with the control bar.
  Widget _buildBottomSection(BuildContext context) {
    return ControlBar(
      remainingRolls: remainingRolls,
      onRollPressed: onRollPressed,
      onPlayPressed: onPlayPressed,
      isPlayEnabled:
          selectedCategory != null && !scores.containsKey(selectedCategory),
    );
  }
}
