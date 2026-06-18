import 'package:flutter/material.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/widgets/dice_widget.dart';
import 'package:poker_dice/widgets/roll_button.dart';
import 'package:poker_dice/widgets/score_sheet.dart';

/// Complete game screen for the poker dice (Yatzy) game.
///
/// Layout:
/// - AppBar: back button, total score, menu button
/// - Score sheet with two-column layout (Minor/Upper, Major/Lower)
/// - Five dice displayed horizontally
/// - Roll button with remaining rolls badge
///
/// Since state management is deferred to Phase 3, this widget accepts
/// callbacks for game actions and receives state as constructor parameters.
class GamePage extends StatelessWidget {
  /// The current dice on the table.
  final List<Dice> dice;

  /// Number of rolls remaining in the current turn.
  final int rollsRemaining;

  /// Categories that have already been scored.
  final Map<ScoreCategory, int> scoredCategories;

  /// The category currently selected (pending confirmation).
  final ScoreCategory? selectedCategory;

  /// Total score across all scored categories plus bonus.
  final int totalScore;

  /// Sum of scored upper-section categories.
  final int upperTotal;

  /// Bonus value: 35 if upper total >= 63, otherwise 0.
  final int bonus;

  /// Called when the player taps the roll button.
  final VoidCallback? onRoll;

  /// Called when the player taps a die to toggle its held state.
  final void Function(int index)? onDiceTap;

  /// Called when the player selects a category to score.
  final void Function(ScoreCategory)? onCategorySelect;

  /// Called when the player taps the menu button.
  final VoidCallback? onMenuTap;

  /// Called when the player taps the back button.
  final VoidCallback? onBackTap;

  /// Creates a [GamePage] with the given game state and callbacks.
  GamePage({
    super.key,
    required this.dice,
    this.rollsRemaining = 3,
    Map<ScoreCategory, int>? scoredCategories,
    this.selectedCategory,
    this.totalScore = 0,
    this.upperTotal = 0,
    this.bonus = 0,
    this.onRoll,
    this.onDiceTap,
    this.onCategorySelect,
    this.onMenuTap,
    this.onBackTap,
  }) : scoredCategories = scoredCategories ?? {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: onBackTap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackTap,
                tooltip: 'Back',
              )
            : null,
        title: _buildAppBarTitle(context),
        actions: [
          if (onMenuTap != null)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuTap,
              tooltip: 'Menu',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Score sheet
            Expanded(
              flex: 3,
              child: ScoreSheet(
                dice: dice,
                scoredCategories: scoredCategories,
                selectedCategory: selectedCategory,
                onCategorySelect: onCategorySelect ?? (_) {},
                upperTotal: upperTotal,
                bonus: bonus,
              ),
            ),
            const SizedBox(height: 16),
            // Dice area
            _buildDiceArea(context),
            const SizedBox(height: 16),
            // Roll button
            _buildRollButton(context),
          ],
        ),
      ),
    );
  }

  /// Builds the app bar title showing total score and player label.
  Widget _buildAppBarTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$totalScore',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'You',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Builds the horizontal row of five dice.
  Widget _buildDiceArea(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        dice.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: DiceWidget(
            dice: dice[index],
            size: 56.0,
            onTap: onDiceTap != null ? () => onDiceTap!(index) : null,
          ),
        ),
      ),
    );
  }

  /// Builds the roll button with remaining rolls badge.
  Widget _buildRollButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: RollButton(rollsRemaining: rollsRemaining, onPressed: onRoll),
    );
  }
}
