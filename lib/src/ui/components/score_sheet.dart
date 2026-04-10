import 'package:flutter/material.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/components/bonus_progress.dart';
import 'package:poker_dice/src/ui/components/score_row.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';

/// A widget that displays the complete score sheet with two columns.
///
/// The score sheet is divided into Minor and Major sections with
/// all scoring categories organized in a compact layout.
class ScoreSheetWidget extends StatelessWidget {
  /// Map of categories to their potential scores (based on current dice).
  final Map<ScoreCategory, int?> potentialScores;

  /// Map of categories to their current scores (null if not scored).
  final Map<ScoreCategory, int?> currentScores;

  /// Set of categories that have been scored.
  final Set<ScoreCategory> scoredCategories;

  /// The current minor section total.
  final int minorTotal;

  /// Callback when a category row is tapped.
  final Function(ScoreCategory)? onCategoryTapped;

  /// Creates a [ScoreSheetWidget].
  const ScoreSheetWidget({
    super.key,
    required this.potentialScores,
    required this.currentScores,
    required this.scoredCategories,
    required this.minorTotal,
    this.onCategoryTapped,
  });

  @override
  Widget build(BuildContext context) {
    final minorCategories = ScoreCategory.values
        .where((c) => c.isMinor)
        .toList();
    final majorCategories = ScoreCategory.values
        .where((c) => c.isMajor)
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
                // Minor column
                Expanded(
                  child: _MinorColumn(
                    categories: minorCategories,
                    potentialScores: potentialScores,
                    currentScores: currentScores,
                    scoredCategories: scoredCategories,
                    minorTotal: minorTotal,
                    onCategoryTapped: onCategoryTapped,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Major column
                Expanded(
                  child: _MajorColumn(
                    categories: majorCategories,
                    potentialScores: potentialScores,
                    currentScores: currentScores,
                    scoredCategories: scoredCategories,
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
              'Minor',
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
              'Major',
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

/// Minor section column of the score sheet (individual die values).
class _MinorColumn extends StatelessWidget {
  final List<ScoreCategory> categories;
  final Map<ScoreCategory, int?> potentialScores;
  final Map<ScoreCategory, int?> currentScores;
  final Set<ScoreCategory> scoredCategories;
  final int minorTotal;
  final Function(ScoreCategory)? onCategoryTapped;

  const _MinorColumn({
    required this.categories,
    required this.potentialScores,
    required this.currentScores,
    required this.scoredCategories,
    required this.minorTotal,
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
            yatzyBonus: false,
            showDieIcon: true, // Show die icons for Minor section
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
          child: Center(child: BonusProgress(upperTotal: minorTotal)),
        ),
      ],
    );
  }
}

/// Major section column of the score sheet (combination categories).
class _MajorColumn extends StatelessWidget {
  final List<ScoreCategory> categories;
  final Map<ScoreCategory, int?> potentialScores;
  final Map<ScoreCategory, int?> currentScores;
  final Set<ScoreCategory> scoredCategories;
  final Function(ScoreCategory)? onCategoryTapped;

  const _MajorColumn({
    required this.categories,
    required this.potentialScores,
    required this.currentScores,
    required this.scoredCategories,
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
              yatzyBonus: false,
              onTap: () => onCategoryTapped?.call(category),
            ),
          )
          .toList(),
    );
  }
}
