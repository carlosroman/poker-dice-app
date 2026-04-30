import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/dice_roll.dart';
import '../services/scoring_service.dart';
import 'score_category_row.dart';

/// A widget that displays the Yatzy scorecard with Upper and Lower sections.
///
/// The scorecard displays all 14 scoring categories in two columns:
/// - Upper Section (left): Ones, Twos, Threes, Fours, Fives, Sixes, Bonus
/// - Lower Section (right): Three of a Kind, Four of a Kind, Full House,
///   Small Straight, Large Straight, Yatzy, Chance
///
/// Each category row shows the category name and its score (if scored).
/// Selected categories are highlighted for visual feedback.
class Scorecard extends StatelessWidget {
  /// The scores for each category.
  ///
  /// If a category is not in the map, it has not been scored yet.
  final Map<Category, int> scores;

  /// The currently selected category.
  ///
  /// If null, no category is currently selected.
  final Category? selectedCategory;

  /// The current dice roll for calculating preview scores.
  ///
  /// If null, no preview scores are shown.
  final DiceRoll? diceRoll;

  /// Callback invoked when a category row is tapped.
  ///
  /// Only callable for categories that have not been scored yet.
  final Function(Category)? onCategoryTapped;

  const Scorecard({
    super.key,
    required this.scores,
    this.selectedCategory,
    required this.diceRoll,
    this.onCategoryTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildUpperColumn(context)),
              const SizedBox(width: 16),
              Expanded(child: _buildLowerColumn(context)),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Upper Section column.
  Widget _buildUpperColumn(BuildContext context) {
    final upperCategories = [
      Category.ones,
      Category.twos,
      Category.threes,
      Category.fours,
      Category.fives,
      Category.sixes,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'UPPER'),
        const SizedBox(height: 8),
        ...upperCategories.map(
          (category) =>
              _buildCategoryRow(context, category, isUpperSection: true),
        ),
        const SizedBox(height: 8),
        _buildDivider(context),
        const SizedBox(height: 8),
        _buildCategoryRow(context, Category.bonus, isUpperSection: true),
      ],
    );
  }

  /// Builds the Lower Section column.
  Widget _buildLowerColumn(BuildContext context) {
    final lowerCategories = [
      Category.threeOfAKind,
      Category.fourOfAKind,
      Category.fullHouse,
      Category.smallStraight,
      Category.largeStraight,
      Category.yatzy,
      Category.chance,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'LOWER'),
        const SizedBox(height: 8),
        ...lowerCategories.map(
          (category) =>
              _buildCategoryRow(context, category, isUpperSection: false),
        ),
      ],
    );
  }

  /// Builds a category row with proper score and selection state.
  Widget _buildCategoryRow(
    BuildContext context,
    Category category, {
    required bool isUpperSection,
  }) {
    final int? score = scores[category];
    final bool isSelected = selectedCategory == category;
    final bool isScored = score != null;

    // Calculate preview score for unscored categories
    int? previewScore;
    if (!isScored && diceRoll != null && category != Category.bonus) {
      previewScore = ScoringService().score(category, diceRoll!);
    }

    return ScoreCategoryRow(
      category: category,
      score: score,
      isSelected: isSelected,
      onTap: (isScored || category == Category.bonus)
          ? null
          : () => onCategoryTapped?.call(category),
      isUpperSection: isUpperSection,
      previewScore: previewScore,
    );
  }

  /// Builds the section header with gradient background.
  Widget _buildSectionHeader(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            text == 'UPPER' ? Icons.diamond : Icons.emoji_events,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the divider between upper section categories and bonus.
  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            theme.colorScheme.primary.withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
