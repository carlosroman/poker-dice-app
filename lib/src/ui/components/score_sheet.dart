import 'package:flutter/material.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/components/bonus_progress.dart';
import 'package:poker_dice/src/ui/components/score_row.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';

/// A widget that displays the complete score sheet with two columns.
///
/// The score sheet is divided into Upper Section and Lower Section with
/// all scoring categories organized in a compact layout.
class ScoreSheetWidget extends StatelessWidget {
  /// Map of categories to their potential scores (based on current dice).
  final Map<ScoreCategory, int?> potentialScores;

  /// Map of categories to their current scores (null if not scored).
  final Map<ScoreCategory, int?> currentScores;

  /// Set of categories that have been scored.
  final Set<ScoreCategory> scoredCategories;

  /// The current upper section total.
  final int upperTotal;

  /// Callback when a category row is tapped.
  final Function(ScoreCategory)? onCategoryTapped;

  /// The currently selected category for scoring.
  final ScoreCategory? selectedCategory;

  /// Creates a [ScoreSheetWidget].
  const ScoreSheetWidget({
    super.key,
    required this.potentialScores,
    required this.currentScores,
    required this.scoredCategories,
    required this.upperTotal,
    this.selectedCategory,
    this.onCategoryTapped,
  });

  @override
  Widget build(BuildContext context) {
    final upperCategories = ScoreCategory.values
        .where((c) => c.isUpper)
        .toList();
    final lowerCategories = ScoreCategory.values
        .where((c) => c.isLower)
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Headers
          _ScoreSheetHeaders(),
          const SizedBox(height: AppSpacing.sm),

          // Score rows
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upper column
                Expanded(
                  child: _UpperColumn(
                    categories: upperCategories,
                    potentialScores: potentialScores,
                    currentScores: currentScores,
                    scoredCategories: scoredCategories,
                    upperTotal: upperTotal,
                    selectedCategory: selectedCategory,
                    onCategoryTapped: onCategoryTapped,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Lower column
                Expanded(
                  child: _LowerColumn(
                    categories: lowerCategories,
                    potentialScores: potentialScores,
                    currentScores: currentScores,
                    scoredCategories: scoredCategories,
                    selectedCategory: selectedCategory,
                    onCategoryTapped: onCategoryTapped,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header widgets for the score sheet columns.
class _ScoreSheetHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppTheme.primaryDark.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Upper Section',
              style: TextStyle(
                color: AppTheme.textOnPrimary,
                fontSize: AppTypography.medium,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppTheme.primaryDark.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Lower Section',
              style: TextStyle(
                color: AppTheme.textOnPrimary,
                fontSize: AppTypography.medium,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

/// Upper section column of the score sheet (individual die values).
class _UpperColumn extends StatelessWidget {
  final List<ScoreCategory> categories;
  final Map<ScoreCategory, int?> potentialScores;
  final Map<ScoreCategory, int?> currentScores;
  final Set<ScoreCategory> scoredCategories;
  final int upperTotal;
  final ScoreCategory? selectedCategory;
  final Function(ScoreCategory)? onCategoryTapped;

  const _UpperColumn({
    required this.categories,
    required this.potentialScores,
    required this.currentScores,
    required this.scoredCategories,
    required this.upperTotal,
    this.selectedCategory,
    this.onCategoryTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...categories.map(
          (category) => ScoreRow(
            key: ValueKey(category),
            category: category,
            potentialScore: potentialScores[category],
            currentScore: currentScores[category],
            isScored: scoredCategories.contains(category),
            isSelected: selectedCategory == category,
            yatzyBonus: false,
            showDieIcon: true, // Show die icons for Upper section
            onTap: () => onCategoryTapped?.call(category),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Bonus progress row
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppTheme.primaryDark.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(child: BonusProgress(upperTotal: upperTotal)),
        ),
      ],
    );
  }
}

/// Lower section column of the score sheet (combination categories).
class _LowerColumn extends StatelessWidget {
  final List<ScoreCategory> categories;
  final Map<ScoreCategory, int?> potentialScores;
  final Map<ScoreCategory, int?> currentScores;
  final Set<ScoreCategory> scoredCategories;
  final ScoreCategory? selectedCategory;
  final Function(ScoreCategory)? onCategoryTapped;

  const _LowerColumn({
    required this.categories,
    required this.potentialScores,
    required this.currentScores,
    required this.scoredCategories,
    this.selectedCategory,
    this.onCategoryTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: categories
          .map(
            (category) => ScoreRow(
              key: ValueKey(category),
              category: category,
              potentialScore: potentialScores[category],
              currentScore: currentScores[category],
              isScored: scoredCategories.contains(category),
              isSelected: selectedCategory == category,
              yatzyBonus: false,
              onTap: () => onCategoryTapped?.call(category),
            ),
          )
          .toList(),
    );
  }
}
