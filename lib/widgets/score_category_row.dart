import 'package:flutter/material.dart';
import '../models/category.dart';

/// A widget that displays a single scoring category row in the scorecard.
///
/// This widget displays the category name and its score (if scored),
/// with visual feedback for different states: available, selected, scored,
/// and zero score.
///
/// Example usage:
/// ```dart
/// ScoreCategoryRow(
///   category: Category.ones,
///   score: null,
///   isSelected: false,
///   onTap: () => selectCategory(Category.ones),
///   isUpperSection: true,
/// )
/// ```
class ScoreCategoryRow extends StatelessWidget {
  /// The category to display.
  final Category category;

  /// The score for this category.
  ///
  /// If null, the category has not been scored yet (shows "---").
  /// If 0, the category was scored as zero.
  final int? score;

  /// Whether this category is currently selected.
  final bool isSelected;

  /// Callback invoked when the category row is tapped.
  final VoidCallback? onTap;

  /// Whether this category belongs to the upper section.
  final bool isUpperSection;

  const ScoreCategoryRow({
    super.key,
    required this.category,
    required this.score,
    required this.isSelected,
    this.onTap,
    required this.isUpperSection,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context, theme),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(context, theme),
            width: _getBorderWidth(),
          ),
          boxShadow: _getBoxShadow(context, theme),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                category.displayName,
                style: _getCategoryTextStyle(context, theme),
              ),
            ),
            const SizedBox(width: 16),
            _buildScoreBox(context, theme, isDark),
          ],
        ),
      ),
    );
  }

  /// Gets the background color based on the current state.
  Color _getBackgroundColor(BuildContext context, ThemeData theme) {
    final bool isScored = score != null;

    if (isSelected) {
      return theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
    }

    if (isScored) {
      return isUpperSection
          ? (theme.brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade100)
          : (theme.brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade50);
    }

    return isUpperSection
        ? (theme.brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.grey.shade50)
        : (theme.brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.white);
  }

  /// Gets the border color based on the current state.
  Color _getBorderColor(BuildContext context, ThemeData theme) {
    if (isSelected) {
      return theme.colorScheme.primary;
    }

    final bool isScored = score != null;
    if (isScored) {
      return theme.colorScheme.secondary.withValues(alpha: 0.3);
    }

    return theme.dividerColor.withValues(alpha: 0.2);
  }

  /// Gets the border width based on the current state.
  double _getBorderWidth() {
    return isSelected ? 2.0 : 1.0;
  }

  /// Gets the box shadows based on the current state.
  List<BoxShadow> _getBoxShadow(BuildContext context, ThemeData theme) {
    if (isSelected) {
      return [
        BoxShadow(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Gets the text style for the category name.
  TextStyle _getCategoryTextStyle(BuildContext context, ThemeData theme) {
    final bool isScored = score != null;

    return TextStyle(
      fontSize: 16,
      fontWeight: isSelected
          ? FontWeight.w600
          : isScored
          ? FontWeight.w500
          : FontWeight.w400,
      color: isSelected
          ? theme.colorScheme.primary
          : isScored
          ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
          : theme.colorScheme.onSurface,
    );
  }

  /// Builds the score display box.
  Widget _buildScoreBox(BuildContext context, ThemeData theme, bool isDark) {
    final bool isScored = score != null;
    final String scoreText = score != null ? score.toString() : '---';

    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: _getScoreBoxColor(context, theme),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getScoreBoxBorderColor(context, theme),
          width: _getScoreBoxBorderWidth(),
        ),
      ),
      child: Center(
        child: Text(
          scoreText,
          style: _getScoreTextStyle(context, theme, isScored),
        ),
      ),
    );
  }

  /// Gets the background color for the score box.
  Color _getScoreBoxColor(BuildContext context, ThemeData theme) {
    final bool isScored = score != null;

    if (isSelected && !isScored) {
      return theme.colorScheme.primary.withValues(alpha: 0.1);
    }

    if (isScored) {
      if (score == 0) {
        return theme.colorScheme.error.withValues(alpha: 0.1);
      }
      return theme.colorScheme.secondary.withValues(alpha: 0.1);
    }

    return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
  }

  /// Gets the border color for the score box.
  Color _getScoreBoxBorderColor(BuildContext context, ThemeData theme) {
    final bool isScored = score != null;

    if (isSelected && !isScored) {
      return theme.colorScheme.primary;
    }

    if (isScored) {
      if (score == 0) {
        return theme.colorScheme.error.withValues(alpha: 0.5);
      }
      return theme.colorScheme.secondary;
    }

    return theme.dividerColor.withValues(alpha: 0.2);
  }

  /// Gets the border width for the score box.
  double _getScoreBoxBorderWidth() {
    final bool isScored = score != null;
    final bool isZero = score == 0;

    if (isSelected && !isScored) {
      return 2.0;
    }

    if (isScored && isZero) {
      return 1.5;
    }

    return 1.0;
  }

  /// Gets the text style for the score value.
  TextStyle _getScoreTextStyle(
    BuildContext context,
    ThemeData theme,
    bool isScored,
  ) {
    return TextStyle(
      fontSize: 18,
      fontWeight: isScored ? FontWeight.w700 : FontWeight.w400,
      color: isScored
          ? (score == 0 ? theme.colorScheme.error : theme.colorScheme.onSurface)
          : theme.colorScheme.onSurface.withValues(alpha: 0.4),
    );
  }
}
