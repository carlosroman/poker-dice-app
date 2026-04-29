import 'package:flutter/material.dart';
import '../models/category.dart';

/// A widget that displays a single scoring category row in the scorecard.
///
/// This widget displays the category name and its score (if scored),
/// with visual feedback for different states: available, selected, scored,
/// and zero score.
///
/// Includes hover effects for web, smooth color transitions, and improved
/// selected state highlighting.
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
class ScoreCategoryRow extends StatefulWidget {
  /// The category to display.
  final Category category;

  /// The score for this category.
  ///
  /// If null, the category has not been scored yet (shows "---").
  /// If 0, the category was scored as zero.
  final int? score;

  /// The potential score for this category based on current dice.
  ///
  /// Shown when the category has not been scored yet and dice are available.
  /// If null, shows '---' for unscored categories.
  final int? previewScore;

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
    this.previewScore,
    required this.isSelected,
    this.onTap,
    required this.isUpperSection,
  });

  @override
  State<ScoreCategoryRow> createState() => _ScoreCategoryRowState();
}

class _ScoreCategoryRowState extends State<ScoreCategoryRow> {
  bool _isHovering = false;

  void _handleHover(bool hovering) {
    if (hovering != _isHovering) {
      setState(() {
        _isHovering = hovering;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
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
                  widget.category.displayName,
                  style: _getCategoryTextStyle(context, theme),
                ),
              ),
              const SizedBox(width: 16),
              _buildScoreBox(context, theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets the background color based on the current state.
  Color _getBackgroundColor(BuildContext context, ThemeData theme) {
    final bool isScored = widget.score != null;

    if (widget.isSelected) {
      return theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
    }

    if (isScored) {
      return widget.isUpperSection
          ? (theme.brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade100)
          : (theme.brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade50);
    }

    return widget.isUpperSection
        ? (theme.brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.grey.shade50)
        : (theme.brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.white);
  }

  /// Gets the border color based on the current state.
  Color _getBorderColor(BuildContext context, ThemeData theme) {
    if (widget.isSelected) {
      return theme.colorScheme.primary;
    }

    final bool isScored = widget.score != null;
    if (isScored) {
      return theme.colorScheme.secondary.withValues(alpha: 0.3);
    }

    return theme.dividerColor.withValues(alpha: 0.2);
  }

  /// Gets the border width based on the current state.
  double _getBorderWidth() {
    return widget.isSelected ? 2.0 : 1.0;
  }

  /// Gets the box shadows based on the current state.
  List<BoxShadow> _getBoxShadow(BuildContext context, ThemeData theme) {
    if (widget.isSelected) {
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
    final bool isScored = widget.score != null;

    return TextStyle(
      fontSize: 16,
      fontWeight: widget.isSelected
          ? FontWeight.w600
          : isScored
          ? FontWeight.w500
          : FontWeight.w400,
      color: widget.isSelected
          ? theme.colorScheme.primary
          : isScored
          ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
          : theme.colorScheme.onSurface,
    );
  }

  /// Builds the score display box.
  Widget _buildScoreBox(BuildContext context, ThemeData theme, bool isDark) {
    final bool isScored = widget.score != null;
    final String scoreText;
    if (widget.score != null) {
      scoreText = widget.score.toString();
    } else if (widget.previewScore != null) {
      scoreText = widget.previewScore.toString();
    } else {
      scoreText = '---';
    }

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
    final bool isScored = widget.score != null;

    if (widget.isSelected && !isScored) {
      return theme.colorScheme.primary.withValues(alpha: 0.1);
    }

    if (isScored) {
      if (widget.score == 0) {
        return theme.colorScheme.error.withValues(alpha: 0.1);
      }
      return theme.colorScheme.secondary.withValues(alpha: 0.1);
    }

    // Preview score - subtle highlight
    if (widget.previewScore != null) {
      return theme.colorScheme.primary.withValues(alpha: 0.05);
    }

    return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
  }

  /// Gets the border color for the score box.
  Color _getScoreBoxBorderColor(BuildContext context, ThemeData theme) {
    final bool isScored = widget.score != null;

    if (widget.isSelected && !isScored) {
      return theme.colorScheme.primary;
    }

    if (isScored) {
      if (widget.score == 0) {
        return theme.colorScheme.error.withValues(alpha: 0.5);
      }
      return theme.colorScheme.secondary;
    }

    // Preview score - subtle border
    if (widget.previewScore != null) {
      return theme.colorScheme.primary.withValues(alpha: 0.3);
    }

    return theme.dividerColor.withValues(alpha: 0.2);
  }

  /// Gets the border width for the score box.
  double _getScoreBoxBorderWidth() {
    final bool isScored = widget.score != null;
    final bool isZero = widget.score == 0;

    if (widget.isSelected && !isScored) {
      return 2.0;
    }

    if (isScored && isZero) {
      return 1.5;
    }

    if (widget.previewScore != null) {
      return 1.0;
    }

    return 1.0;
  }

  /// Gets the text style for the score value.
  TextStyle _getScoreTextStyle(
    BuildContext context,
    ThemeData theme,
    bool isScored,
  ) {
    if (isScored) {
      return TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: widget.score == 0
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface,
      );
    }

    // Preview score (not yet committed) - use lighter style
    if (widget.previewScore != null) {
      return TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.primary,
      );
    }

    // No score, no preview
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
    );
  }
}
