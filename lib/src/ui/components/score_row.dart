import 'package:flutter/material.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';

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

  /// Whether the Yatzy bonus applies (+50).
  final bool yatzyBonus;

  /// Callback when the row is tapped.
  final VoidCallback? onTap;

  /// Creates a [ScoreRow].
  const ScoreRow({
    super.key,
    required this.category,
    this.potentialScore,
    this.currentScore,
    this.isScored = false,
    this.yatzyBonus = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
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
              _CategoryIcon(category: category),
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
    );
  }
}

/// Displays the category icon.
class _CategoryIcon extends StatelessWidget {
  final ScoreCategory category;

  const _CategoryIcon({required this.category});

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
    switch (category) {
      case ScoreCategory.aces:
        return const _DieFaceIcon(dots: 1);
      case ScoreCategory.twos:
        return const _DieFaceIcon(dots: 2);
      case ScoreCategory.threes:
        return const _DieFaceIcon(dots: 3);
      case ScoreCategory.fours:
        return const _DieFaceIcon(dots: 4);
      case ScoreCategory.fives:
        return const _DieFaceIcon(dots: 5);
      case ScoreCategory.sixes:
        return const _DieFaceIcon(dots: 6);
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
}

/// A small die face icon for upper section categories.
class _DieFaceIcon extends StatelessWidget {
  final int dots;

  const _DieFaceIcon({required this.dots});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Build dots based on value
        if (dots >= 1) _Dot(position: Alignment.center),
        if (dots >= 2) ...[
          _Dot(position: Alignment.topLeft, offset: const Offset(4, 4)),
          _Dot(position: Alignment.bottomRight, offset: const Offset(-4, -4)),
        ],
        if (dots >= 4) ...[
          _Dot(position: Alignment.topRight, offset: const Offset(-4, 4)),
          _Dot(position: Alignment.bottomLeft, offset: const Offset(4, -4)),
        ],
        if (dots == 6) ...[
          _Dot(position: Alignment.centerLeft, offset: const Offset(4, 0)),
          _Dot(position: Alignment.centerRight, offset: const Offset(-4, 0)),
        ],
      ],
    );
  }
}

/// A small black dot for die face icons.
class _Dot extends StatelessWidget {
  final AlignmentGeometry position;
  final Offset offset;

  const _Dot({this.position = Alignment.center, this.offset = Offset.zero});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: position,
        child: Transform.translate(
          offset: offset,
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
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
