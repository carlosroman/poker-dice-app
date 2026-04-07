import 'package:flutter/material.dart';

import '../../domain/models/score_category.dart';
import '../../domain/models/score_sheet.dart' as domain_model;
import '../theme/app_theme.dart';
import 'score_category_row.dart';

/// A scrollable widget displaying the complete score sheet for a Yatzy dice game.
///
/// Shows all 13 scoring categories organized into Upper and Lower sections,
/// with section totals, bonus indicator, and grand total.
///
/// ## Structure
/// - Header row with "Category" and "Score" labels
/// - Upper Section: Aces through Sixes (6 categories)
/// - Upper Section divider with subtotal and bonus indicator
/// - Lower Section: ThreeOfKind through Chance (7 categories)
/// - Lower Section divider with subtotal
/// - Grand Total at bottom with breakdown
///
/// ## Features
/// - Semantic labels for accessibility
/// - Category selection callback for valid categories
/// - Animated score transitions
/// - Bonus indicator when upper section >= 63 points
/// - Responsive design with proper spacing
///
/// ## Scoring Rules
/// The upper section bonus of 35 points is awarded when the upper total
/// reaches 63 or more points (one of each face value).
///
/// Example:
/// ```dart
/// ScoreSheet(
///   scoreSheet: gameBloc.state.scoreSheet,
///   validCategories: gameBloc.state.validCategories,
///   onCategorySelected: (category) {
///     gameBloc.add(CategorySelected(category));
///   },
/// )
/// ```
class ScoreSheet extends StatelessWidget {
  /// The score sheet model containing all scores.
  ///
  /// Contains scores for all 13 categories including
  /// upper section (Aces-Sixes), lower section, and totals.
  final domain_model.ScoreSheet scoreSheet;

  /// Callback when a category is selected.
  ///
  /// Invoked when the user taps on an empty, valid category.
  /// Used to update the score for the selected category.
  final Function(ScoreCategory)? onCategorySelected;

  /// List of categories the user can select.
  ///
  /// Typically contains only the empty (not yet scored) categories
  /// that are valid for selection based on current dice values.
  /// Pass an empty list if selection is not needed (e.g., game over).
  final List<ScoreCategory> validCategories;

  /// Animation duration for state transitions.
  static const Duration _animationDuration = Duration(milliseconds: 300);

  /// Creates a [ScoreSheet] instance.
  ///
  /// The [scoreSheet] parameter must not be null.
  /// The [validCategories] defaults to an empty list if not provided.
  const ScoreSheet({
    super.key,
    required this.scoreSheet,
    this.onCategorySelected,
    this.validCategories = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row
        _buildHeader(isDark),
        const SizedBox(height: AppTheme.spacingSm),
        // Scrollable content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
            children: [
              // Upper Section
              _buildUpperSection(isDark),
              const SizedBox(height: AppTheme.spacingSm),
              // Lower Section
              _buildLowerSection(isDark),
              const SizedBox(height: AppTheme.spacingMd),
              // Grand Total
              _buildGrandTotal(isDark),
              const SizedBox(height: AppTheme.spacingMd),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the header row with "Category" and "Score" labels.
  ///
  /// Returns a [Row] widget with styled text for column headers.
  ///
  /// Parameters:
  /// - [isDark]: Whether the current theme is dark mode
  ///
  /// Returns:
  /// A configured header row widget.
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Category',
              style: TextStyle(
                fontSize: AppTheme.bodyMedium,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFE0E0E0) : AppTheme.textPrimary,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Score',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTheme.bodyMedium,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFE0E0E0) : AppTheme.textPrimary,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Upper Section with 6 categories (Aces through Sixes).
  ///
  /// Displays all upper section categories with their scores,
  /// followed by the section total and bonus indicator.
  ///
  /// Parameters:
  /// - [isDark]: Whether the current theme is dark mode
  ///
  /// Returns:
  /// A [Column] widget containing upper section categories and total.
  Widget _buildUpperSection(bool isDark) {
    final upperCategories = ScoreCategoryHelper.getUpperCategories();
    final upperTotal = scoreSheet.getUpperTotal();
    final bonus = scoreSheet.getBonus();
    final hasBonus = upperTotal >= 63;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upper Section categories
        ...upperCategories.map((category) {
          final isScored = scoreSheet.isCategoryScored(category);
          final score = scoreSheet.scores[category];
          final isSelected = !isScored && validCategories.contains(category);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
            child: ScoreCategoryRow(
              category: category,
              score: score,
              isSelected: isSelected,
              onTap: isSelected
                  ? () => onCategorySelected?.call(category)
                  : null,
            ),
          );
        }),
        // Upper Section divider with total and bonus
        _buildSectionDivider(
          title: 'Upper Total',
          total: upperTotal,
          bonus: bonus,
          hasBonus: hasBonus,
          isDark: isDark,
        ),
      ],
    );
  }

  /// Builds the Lower Section with 7 categories.
  ///
  /// Displays all lower section categories:
  /// ThreeOfKind, FourOfKind, FullHouse, SmallStraight, LargeStraight, Yatzy, Chance.
  ///
  /// Parameters:
  /// - [isDark]: Whether the current theme is dark mode
  ///
  /// Returns:
  /// A [Column] widget containing lower section categories and total.
  Widget _buildLowerSection(bool isDark) {
    final lowerCategories = ScoreCategoryHelper.getLowerCategories();
    final lowerTotal = scoreSheet.getLowerTotal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lower Section categories
        ...lowerCategories.map((category) {
          final isScored = scoreSheet.isCategoryScored(category);
          final score = scoreSheet.scores[category];
          final isSelected = !isScored && validCategories.contains(category);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
            child: ScoreCategoryRow(
              category: category,
              score: score,
              isSelected: isSelected,
              onTap: isSelected
                  ? () => onCategorySelected?.call(category)
                  : null,
            ),
          );
        }),
        // Lower Section divider with total
        _buildSectionDivider(
          title: 'Lower Total',
          total: lowerTotal,
          bonus: 0,
          hasBonus: false,
          isDark: isDark,
        ),
      ],
    );
  }

  /// Builds a section divider with total score and optional bonus.
  ///
  /// Creates a styled divider with the section title, total score,
  /// and bonus indicator if applicable.
  ///
  /// Parameters:
  /// - [title]: The section title (e.g., "Upper Total", "Lower Total")
  /// - [total]: The section total score
  /// - [bonus]: The bonus amount (0 if no bonus)
  /// - [hasBonus]: Whether a bonus is awarded
  /// - [isDark]: Whether the current theme is dark mode
  ///
  /// Returns:
  /// A [Container] widget with the section divider and totals.
  Widget _buildSectionDivider({
    required String title,
    required int total,
    required int bonus,
    required bool hasBonus,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: AppTheme.spacingSm),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : AppTheme.scoreBackgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          // Divider line with title
          Row(
            children: [
              Expanded(
                child: Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF424242)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTheme.bodySmall,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFB0B0B0)
                        : AppTheme.textSecondary,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF424242)
                      : const Color(0xFFE0E0E0),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          // Total score row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: AppTheme.bodyLarge,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFE0E0E0)
                      : AppTheme.textPrimary,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: TextStyle(
                      fontSize: AppTheme.bodyLarge,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFE0E0E0)
                          : AppTheme.textPrimary,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                  if (hasBonus) ...[
                    const SizedBox(width: AppTheme.spacingSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(
                          color: AppTheme.successColor,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '+$bonus bonus',
                        style: TextStyle(
                          fontSize: AppTheme.bodySmall,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the Grand Total row at the bottom.
  ///
  /// Displays the final score with a breakdown of upper total,
  /// lower total, and bonus. Features gradient background and
  /// special styling when bonus is awarded.
  ///
  /// Parameters:
  /// - [isDark]: Whether the current theme is dark mode
  ///
  /// Returns:
  /// A [Container] widget with the grand total display.
  Widget _buildGrandTotal(bool isDark) {
    final grandTotal = scoreSheet.getTotal();
    final upperTotal = scoreSheet.getUpperTotal();
    final lowerTotal = scoreSheet.getLowerTotal();
    final bonus = scoreSheet.getBonus();
    final hasBonus = upperTotal >= 63;

    return Semantics(
      label: 'Grand Total: $grandTotal points',
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasBonus
                ? [
                    (isDark ? const Color(0xFF3A3A3A) : AppTheme.primaryColor)
                        .withValues(alpha: 0.1),
                    (isDark ? const Color(0xFF3A3A3A) : AppTheme.secondaryColor)
                        .withValues(alpha: 0.15),
                  ]
                : [
                    isDark
                        ? const Color(0xFF2C2C2C)
                        : AppTheme.scoreBackgroundColor,
                    isDark
                        ? const Color(0xFF2C2C2C)
                        : AppTheme.scoreBackgroundColor,
                  ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: hasBonus
                ? AppTheme.secondaryColor
                : (isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0)),
            width: hasBonus ? 2.0 : 1.0,
          ),
          boxShadow: hasBonus
              ? [
                  BoxShadow(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                    blurRadius: 12.0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Breakdown row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Upper: $upperTotal',
                  style: TextStyle(
                    fontSize: AppTheme.bodySmall,
                    color: isDark
                        ? const Color(0xFFB0B0B0)
                        : AppTheme.textSecondary,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                if (hasBonus) ...[
                  const SizedBox(width: AppTheme.spacingSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXs,
                      vertical: AppTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Text(
                      '+$bonus',
                      style: TextStyle(
                        fontSize: AppTheme.bodySmall,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Lower: $lowerTotal',
                  style: TextStyle(
                    fontSize: AppTheme.bodySmall,
                    color: isDark
                        ? const Color(0xFFB0B0B0)
                        : AppTheme.textSecondary,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            // Grand total
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Grand Total:',
                  style: TextStyle(
                    fontSize: AppTheme.bodyLarge,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFE0E0E0)
                        : AppTheme.textPrimary,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                AnimatedSwitcher(
                  duration: _animationDuration,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                  child: Text(
                    '$grandTotal',
                    key: ValueKey(grandTotal),
                    style: TextStyle(
                      fontSize: AppTheme.headingMedium,
                      fontWeight: FontWeight.bold,
                      color: hasBonus
                          ? AppTheme.secondaryColor
                          : (isDark
                                ? const Color(0xFFE0E0E0)
                                : AppTheme.primaryColor),
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
