import 'package:flutter/material.dart';

import '../../domain/models/score_category.dart';
import '../theme/app_theme.dart';

/// A row widget displaying a score category for the Yatzy dice game.
///
/// Shows the category name and score with different styling based on state:
/// - [isSelected]: Highlighted background, enabled cursor (can be selected)
/// - [score] is not null: Greyed out, shows the score (already scored)
/// - Scored but not selected: Dimmed appearance (disabled)
///
/// ## Features
/// - Animated scale effect on selection
/// - Color-coded states (selected, scored, disabled)
/// - Optional Yatzy bonus indicator (+50)
/// - Ripple and highlight animations
/// - Accessibility support with semantic labels
///
/// ## States
/// | State | Appearance | Behavior |
/// |-------|------------|----------|
/// | Selected | Blue highlight, bold text | Tappable, triggers callback |
/// | Scored | Greyed out, shows score | Non-interactive |
/// | Disabled | Dimmed, no score | Non-interactive |
///
/// Example:
/// ```dart
/// ScoreCategoryRow(
///   category: ScoreCategory.yatzy,
///   score: null,
///   isSelected: true,
///   showYatzyBonus: true,
///   onTap: () => _selectCategory(ScoreCategory.yatzy),
/// )
/// ```
class ScoreCategoryRow extends StatefulWidget {
  /// The category to display.
  ///
  /// One of the 13 Yatzy scoring categories:
  /// Aces, Twos, Threes, Fours, Fives, Sixes,
  /// ThreeOfKind, FourOfKind, FullHouse, SmallStraight,
  /// LargeStraight, Yatzy, Chance.
  final ScoreCategory category;

  /// Current score (null if not scored yet).
  ///
  /// When null, the category is empty and may be selectable.
  /// When not null, displays the scored value.
  final int? score;

  /// Whether the category can be selected (empty and valid).
  ///
  /// When true, the row is highlighted and tappable.
  /// When false, the row is displayed in scored or disabled state.
  final bool isSelected;

  /// Whether to show the +50 bonus indicator (for Yatzy).
  ///
  /// Set to true for the Yatzy category to show potential bonus.
  final bool showYatzyBonus;

  /// Callback triggered when the row is tapped.
  ///
  /// Only invoked when [isSelected] is true.
  /// Use to update the score for the selected category.
  final VoidCallback? onTap;

  /// Animation duration for state transitions.
  static const Duration _animationDuration = Duration(milliseconds: 200);

  /// Animation duration for selection effect.
  static const Duration _selectionDuration = Duration(milliseconds: 250);

  /// Creates a [ScoreCategoryRow] instance.
  ///
  /// The [category] parameter must not be null.
  /// The [isSelected] and [showYatzyBonus] default to false.
  const ScoreCategoryRow({
    super.key,
    required this.category,
    this.score,
    this.isSelected = false,
    this.showYatzyBonus = false,
    this.onTap,
  });

  @override
  State<ScoreCategoryRow> createState() => _ScoreCategoryRowState();
}

class _ScoreCategoryRowState extends State<ScoreCategoryRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectionController = AnimationController(
      duration: ScoreCategoryRow._selectionDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ScoreCategoryRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onTap != null && !oldWidget.isSelected && widget.isSelected) {
      _selectionController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: _buildAccessibilityLabel(),
      button: widget.onTap != null,
      enabled: widget.onTap != null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _selectionController,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: AnimatedContainer(
            duration: ScoreCategoryRow._animationDuration,
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            decoration: _buildDecoration(isDark),
            child: _buildRowContent(isDark),
          ),
        ),
      ),
    );
  }

  /// Builds the accessibility label for screen readers.
  ///
  /// Returns a descriptive string including category name,
  /// current score state, and any bonus information.
  ///
  /// Returns:
  /// A formatted accessibility label string.
  ///
  /// Example:
  /// "Yatzy: not scored, selectable, Yatzy bonus available"
  String _buildAccessibilityLabel() {
    final scoreText = widget.score != null
        ? '${widget.score} points'
        : 'not scored';
    final stateText = widget.isSelected
        ? 'selectable'
        : (widget.score != null ? 'scored' : 'disabled');
    final bonusText = widget.showYatzyBonus ? 'Yatzy bonus available' : '';

    return '${widget.category.displayName}: $scoreText, $stateText${bonusText.isNotEmpty ? ', $bonusText' : ''}';
  }

  /// Builds the decoration based on the current state.
  ///
  /// Returns different decorations for selected, scored, and disabled states.
  ///
  /// Parameters:
  /// - [isDark]: Whether the current theme is dark mode
  ///
  /// Returns:
  /// A [BoxDecoration] configured for the current state.
  BoxDecoration _buildDecoration(bool isDark) {
    if (widget.isSelected) {
      // Selected state: highlighted background
      return BoxDecoration(
        color:
            (isDark
                    ? AppTheme.selectedColor
                    : AppTheme.selectedColor.withValues(alpha: 0.12))
                .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.selectedColor, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.selectedColor.withValues(alpha: 0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else if (widget.score != null) {
      // Scored state: greyed out
      return BoxDecoration(
        color:
            (isDark ? const Color(0xFF2C2C2C) : AppTheme.scoreBackgroundColor)
                .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
          width: 1.0,
        ),
      );
    } else {
      // Disabled state: dimmed appearance
      return BoxDecoration(
        color:
            (isDark ? const Color(0xFF2C2C2C) : AppTheme.scoreBackgroundColor)
                .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
          width: 1.0,
        ),
      );
    }
  }

  /// Builds the row content with category name and score.
  ///
  /// Creates a [Row] widget with the category name on the left
  /// and score display on the right.
  ///
  /// Parameters:
  /// - [isDark]: Whether the current theme is dark mode
  ///
  /// Returns:
  /// A configured [Row] widget.
  Widget _buildRowContent(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Category name
        Expanded(
          child: Text(
            widget.category.displayName,
            style: _buildTextStyle(isDark),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        // Score display or placeholder
        _buildScoreDisplay(isDark),
      ],
    );
  }

  /// Builds the text style based on the current state.
  ///
  /// Returns different text styles for selected, scored, and disabled states.
  ///
  /// Parameters:
  /// - [isDark]: Whether the current theme is dark mode
  ///
  /// Returns:
  /// A [TextStyle] configured for the current state.
  TextStyle _buildTextStyle(bool isDark) {
    if (widget.isSelected) {
      return TextStyle(
        fontSize: AppTheme.bodyLarge,
        fontWeight: FontWeight.w600,
        color: AppTheme.selectedColor,
        fontFamily: AppTheme.fontFamily,
      );
    } else if (widget.score != null) {
      return TextStyle(
        fontSize: AppTheme.bodyLarge,
        fontWeight: FontWeight.normal,
        color: isDark ? const Color(0xFFB0B0B0) : AppTheme.textSecondary,
        fontFamily: AppTheme.fontFamily,
      );
    } else {
      return TextStyle(
        fontSize: AppTheme.bodyLarge,
        fontWeight: FontWeight.normal,
        color: isDark
            ? const Color(0xFF707070)
            : AppTheme.textSecondary.withValues(alpha: 0.6),
        fontFamily: AppTheme.fontFamily,
      );
    }
  }

  /// Builds the score display or placeholder widget.
  ///
  /// Shows the score if scored, or a placeholder dash if not.
  /// Includes optional Yatzy bonus indicator.
  ///
  /// Parameters:
  /// - [isDark]: Whether the current theme is dark mode
  ///
  /// Returns:
  /// A widget displaying the score or placeholder.
  Widget _buildScoreDisplay(bool isDark) {
    final scoreText = widget.score?.toString() ?? '-';
    final isScored = widget.score != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: ScoreCategoryRow._animationDuration,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(sizeFactor: animation, child: child),
            );
          },
          child: Text(
            scoreText,
            key: ValueKey('score-$scoreText'),
            style: TextStyle(
              fontSize: AppTheme.bodyLarge,
              fontWeight: isScored ? FontWeight.w600 : FontWeight.normal,
              color: isScored
                  ? (isDark ? const Color(0xFFE0E0E0) : AppTheme.textPrimary)
                  : (isDark
                        ? const Color(0xFF707070)
                        : AppTheme.textSecondary.withValues(alpha: 0.6)),
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ),
        if (widget.showYatzyBonus) ...[
          const SizedBox(width: AppTheme.spacingXs),
          _buildBonusIndicator(isDark),
        ],
      ],
    );
  }

  /// Builds the Yatzy bonus indicator (+50).
  ///
  /// Displays a small badge showing the potential +50 bonus
  /// for scoring a Yatzy (five of a kind).
  ///
  /// Parameters:
  /// - [isDark]: Whether the current theme is dark mode
  ///
  /// Returns:
  /// A [Container] widget with the bonus badge.
  Widget _buildBonusIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXs,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.successColor, width: 1.0),
      ),
      child: Text(
        '+50',
        style: TextStyle(
          fontSize: AppTheme.bodySmall,
          fontWeight: FontWeight.bold,
          color: AppTheme.successColor,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
    );
  }
}

/// A divider widget for separating Upper and Lower sections.
///
/// Used between score sections to visually separate categories
/// with horizontal lines and a section title.
///
/// Example:
/// ```dart
/// ScoreSectionDivider(title: 'Upper Section')
/// ```
class ScoreSectionDivider extends StatelessWidget {
  /// The section title to display.
  ///
  /// Typically "Upper Section" or "Lower Section".
  final String title;

  /// Creates a [ScoreSectionDivider] instance.
  ///
  /// The [title] parameter must not be null.
  const ScoreSectionDivider({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppTheme.spacingMd,
        bottom: AppTheme.spacingSm,
        left: AppTheme.spacingMd,
        right: AppTheme.spacingMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              height: 1,
              color: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
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
              color: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
            ),
          ),
        ],
      ),
    );
  }
}
