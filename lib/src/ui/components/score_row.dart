import 'package:flutter/material.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';
import '../utils/accessibility_utils.dart';

/// A widget that displays a single row in the score sheet.
///
/// Layout: [Icon] | [Potential Score] | [Current Score Box]
/// The row is clickable to select the category for scoring.
class ScoreRow extends StatelessWidget {
  /// The category this row represents.
  final ScoreCategory category;

  /// The potential score for this category based on current dice.
  final int? potentialScore;

  /// The current score for this category (null if not scored yet).
  final int? currentScore;

  /// Whether this category has been scored.
  final bool isScored;

  /// Whether this category is currently selected.
  final bool isSelected;

  /// Whether the Yatzy bonus applies (+50).
  final bool yatzyBonus;

  /// Whether to show a die face icon (for Minor section).
  final bool showDieIcon;

  /// Callback when the row is tapped.
  final VoidCallback? onTap;

  /// Creates a [ScoreRow].
  const ScoreRow({
    super.key,
    required this.category,
    this.potentialScore,
    this.currentScore,
    this.isScored = false,
    this.isSelected = false,
    this.yatzyBonus = false,
    this.showDieIcon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppTheme.primaryDark.withValues(alpha: 0.5)
          : Colors.transparent,
      child: Semantics(
        label: AccessibilityUtils.getScoreRowLabel(
          category.displayName,
          potentialScore,
          currentScore,
        ),
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                // Icon column
                _CategoryIcon(category: category, showDieIcon: showDieIcon),
                const SizedBox(width: AppSpacing.sm),

                // Potential score column
                Expanded(
                  flex: 2,
                  child: Text(
                    potentialScore?.toString() ?? '-',
                    style: const TextStyle(
                      color: AppTheme.textOnPrimary,
                      fontSize: AppTypography.medium,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Current score column
                _ScoreBox(
                  score: currentScore,
                  isScored: isScored,
                  yatzyBonus: yatzyBonus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays the category icon.
class _CategoryIcon extends StatelessWidget {
  final ScoreCategory category;
  final bool showDieIcon;

  const _CategoryIcon({required this.category, this.showDieIcon = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.accentYellow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: _buildIcon(),
    );
  }

  Widget _buildIcon() {
    // Show die face icon for Minor section (die values 1-6)
    if (showDieIcon) {
      final dieValue = _getDieValueForCategory(category);
      return _DieFaceIcon(dots: dieValue);
    }

    switch (category) {
      case ScoreCategory.aces:
      case ScoreCategory.twos:
      case ScoreCategory.threes:
      case ScoreCategory.fours:
      case ScoreCategory.fives:
      case ScoreCategory.sixes:
        // Fallback for Minor section without die icon
        return _DieFaceIcon(dots: _getDieValueForCategory(category));
      case ScoreCategory.threeOfKind:
        return const Text(
          '3x',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );
      case ScoreCategory.fourOfKind:
        return const Text(
          '4x',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );
      case ScoreCategory.fullHouse:
        return const Icon(Icons.home, color: Colors.black, size: 18);
      case ScoreCategory.smallStraight:
        return const Icon(Icons.card_giftcard, color: Colors.black, size: 18);
      case ScoreCategory.largeStraight:
        return const Icon(Icons.card_giftcard, color: Colors.black, size: 18);
      case ScoreCategory.yatzy:
        return const Text(
          'Y',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );
      case ScoreCategory.chance:
        return const Icon(Icons.help, color: Colors.black, size: 18);
    }
  }

  int _getDieValueForCategory(ScoreCategory category) {
    switch (category) {
      case ScoreCategory.aces:
        return 1;
      case ScoreCategory.twos:
        return 2;
      case ScoreCategory.threes:
        return 3;
      case ScoreCategory.fours:
        return 4;
      case ScoreCategory.fives:
        return 5;
      case ScoreCategory.sixes:
        return 6;
      default:
        return 1;
    }
  }
}

/// A small die face icon for upper section categories.
class _DieFaceIcon extends StatelessWidget {
  final int dots;

  const _DieFaceIcon({required this.dots});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Value 1: Center
        if (dots == 1)
          Positioned.fill(
            child: Align(alignment: Alignment.center, child: _DieDot()),
          ),
        // Value 2: Top-left and bottom-right
        if (dots == 2)
          Positioned.fill(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _DieDot(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _DieDot(),
                  ),
                ),
              ],
            ),
          ),
        // Value 3: Top-left, center, bottom-right
        if (dots == 3)
          Positioned.fill(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _DieDot(),
                  ),
                ),
                Align(alignment: Alignment.center, child: _DieDot()),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _DieDot(),
                  ),
                ),
              ],
            ),
          ),
        // Value 4: Four corners
        if (dots == 4)
          Positioned.fill(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _DieDot(),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _DieDot(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _DieDot(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _DieDot(),
                  ),
                ),
              ],
            ),
          ),
        // Value 5: Four corners + center
        if (dots == 5)
          Positioned.fill(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _DieDot(),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _DieDot(),
                  ),
                ),
                Align(alignment: Alignment.center, child: _DieDot()),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _DieDot(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _DieDot(),
                  ),
                ),
              ],
            ),
          ),
        // Value 6: Two columns of 3
        if (dots == 6)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_DieDot(), _DieDot(), _DieDot()],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_DieDot(), _DieDot(), _DieDot()],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A small black dot for die face icons.
class _DieDot extends StatelessWidget {
  const _DieDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Displays the current score in a light blue box.
class _ScoreBox extends StatelessWidget {
  final int? score;
  final bool isScored;
  final bool yatzyBonus;

  const _ScoreBox({
    required this.score,
    required this.isScored,
    required this.yatzyBonus,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppTheme.scoreBoxLightBlue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              score?.toString() ?? '',
              style: const TextStyle(
                color: AppTheme.scoreTextWhite,
                fontSize: AppTypography.medium,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (yatzyBonus && isScored)
            const Text(
              '+50',
              style: TextStyle(
                color: AppTheme.accentOrange,
                fontSize: AppTypography.small,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
