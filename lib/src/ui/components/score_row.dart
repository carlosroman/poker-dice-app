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
    return Center(
      child: CustomPaint(
        size: const Size(28, 28),
        painter: _DieFacePainter(dots: dots),
      ),
    );
  }
}

/// Paints die face dots on a canvas.
class _DieFacePainter extends CustomPainter {
  final int dots;

  _DieFacePainter({required this.dots});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final dotRadius = 3.0;
    final center = Offset(size.width / 2, size.height / 2);
    final offset = size.width * 0.25;

    // Define dot positions for each value
    final positions = <Offset>[];

    switch (dots) {
      case 1:
        positions.add(center);
        break;
      case 2:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
      case 3:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(center);
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
      case 4:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(Offset(center.dx + offset, center.dy - offset));
        positions.add(Offset(center.dx - offset, center.dy + offset));
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
      case 5:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(Offset(center.dx + offset, center.dy - offset));
        positions.add(center);
        positions.add(Offset(center.dx - offset, center.dy + offset));
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
      case 6:
        final colOffset = offset * 0.8;
        final rowOffset = offset * 1.2;
        positions.add(Offset(center.dx - colOffset, center.dy - rowOffset));
        positions.add(Offset(center.dx + colOffset, center.dy - rowOffset));
        positions.add(Offset(center.dx - colOffset, center.dy));
        positions.add(Offset(center.dx + colOffset, center.dy));
        positions.add(Offset(center.dx - colOffset, center.dy + rowOffset));
        positions.add(Offset(center.dx + colOffset, center.dy + rowOffset));
        break;
    }

    // Draw all dots
    for (final pos in positions) {
      canvas.drawCircle(pos, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DieFacePainter oldDelegate) =>
      oldDelegate.dots != dots;
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
