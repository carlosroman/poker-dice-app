import 'package:flutter/material.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/domain/models/score_sheet.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';
import 'package:poker_dice/src/ui/utils/accessibility_utils.dart';

/// The game over page displaying the final score and breakdown.
///
/// Shows a large final score, category breakdown, and a "New Game" button.
class GameOverPage extends StatelessWidget {
  /// The final score sheet with all categories scored.
  final ScoreSheet scoreSheet;

  /// Callback when the new game button is tapped.
  final VoidCallback? onNewGameTapped;

  /// Callback for back navigation.
  final VoidCallback? onBackTapped;

  /// Callback for viewing high scores.
  final VoidCallback? onViewHighScoresTapped;

  /// Creates a [GameOverPage].
  const GameOverPage({
    super.key,
    required this.scoreSheet,
    this.onNewGameTapped,
    this.onBackTapped,
    this.onViewHighScoresTapped,
  });

  @override
  Widget build(BuildContext context) {
    final totalScore = scoreSheet.getTotal();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundGradientStart,
              AppTheme.backgroundGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBackTapped,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.textOnPrimary,
                    ),
                  ),
                ),

                const Spacer(),

                // Game Over Title
                const Text(
                  'Game Over!',
                  style: TextStyle(
                    color: AppTheme.textOnPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Final Score
                Semantics(
                  label: AccessibilityUtils.getTotalScoreLabel(totalScore),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: AppSpacing.xl,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.accentYellow,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '$totalScore',
                      style: const TextStyle(
                        color: AppTheme.accentYellow,
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Score Breakdown
                Expanded(child: _ScoreBreakdown(scoreSheet: scoreSheet)),

                const SizedBox(height: AppSpacing.lg),

                // New Game Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNewGameTapped,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'New Game',
                      style: TextStyle(
                        fontSize: AppTypography.extraLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // View High Scores Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onViewHighScoresTapped,
                    icon: const Icon(Icons.emoji_events),
                    label: const Text(
                      'View High Scores',
                      style: TextStyle(
                        fontSize: AppTypography.extraLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentYellow,
                      side: const BorderSide(
                        color: AppTheme.accentYellow,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget displaying the score breakdown by category.
class _ScoreBreakdown extends StatelessWidget {
  final ScoreSheet scoreSheet;

  const _ScoreBreakdown({required this.scoreSheet});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Minor Section
          _CategorySection(
            title: 'Minor Section',
            categories: ScoreSheet.minorCategories,
            scoreSheet: scoreSheet,
          ),

          // Minor Total
          _ScoreRow(
            label: 'Minor Total',
            score: scoreSheet.getMinorTotal(),
            isTotal: true,
          ),

          // Bonus
          _ScoreRow(
            label: 'Bonus',
            score: scoreSheet.getBonus(),
            isBonus: scoreSheet.getBonus() > 0,
          ),

          const SizedBox(height: AppSpacing.md),

          // Major Section
          _CategorySection(
            title: 'Major Section',
            categories: ScoreSheet.majorCategories,
            scoreSheet: scoreSheet,
          ),

          // Major Total
          _ScoreRow(
            label: 'Major Total',
            score: scoreSheet.getMajorTotal(),
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

/// A section header for upper or lower categories.
class _CategorySection extends StatelessWidget {
  final String title;
  final List<ScoreCategory> categories;
  final ScoreSheet scoreSheet;

  const _CategorySection({
    required this.title,
    required this.categories,
    required this.scoreSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppTheme.primaryDark.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textOnPrimary,
              fontSize: AppTypography.medium,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...categories.map(
          (category) => _CategoryRow(
            category: category,
            score: scoreSheet.scores[category] ?? 0,
          ),
        ),
      ],
    );
  }
}

/// A single category row in the score breakdown.
class _CategoryRow extends StatelessWidget {
  final ScoreCategory category;
  final int score;

  const _CategoryRow({required this.category, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category.displayName,
            style: const TextStyle(
              color: AppTheme.textOnPrimary,
              fontSize: AppTypography.medium,
            ),
          ),
          Text(
            score.toString(),
            style: const TextStyle(
              color: AppTheme.textOnPrimary,
              fontSize: AppTypography.medium,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A summary row for totals and bonus.
class _ScoreRow extends StatelessWidget {
  final String label;
  final int score;
  final bool isTotal;
  final bool isBonus;

  const _ScoreRow({
    required this.label,
    required this.score,
    this.isTotal = false,
    this.isBonus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textOnPrimary,
              fontSize: AppTypography.medium,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            score.toString(),
            style: TextStyle(
              color: isBonus ? AppTheme.accentOrange : AppTheme.textOnPrimary,
              fontSize: AppTypography.medium,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
