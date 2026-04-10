import 'package:flutter/material.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';
import '../utils/accessibility_utils.dart';

/// A widget that displays progress toward the upper section bonus.
///
/// Shows "X/63" progress and displays "+35" bonus indicator when
/// the upper section total reaches 63 or more.
class BonusProgress extends StatelessWidget {
  /// The current upper section total score.
  final int upperTotal;

  /// Whether the bonus has been earned.
  final bool bonusEarned;

  /// Creates a [BonusProgress].
  const BonusProgress({
    super.key,
    required this.upperTotal,
    this.bonusEarned = false,
  });

  @override
  Widget build(BuildContext context) {
    final showBonus = upperTotal >= 63;

    return Semantics(
      label: AccessibilityUtils.getBonusProgressLabel(
        upperTotal,
        63,
        showBonus ? 35 : 0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: showBonus ? AppTheme.accentOrange : AppTheme.scoreBoxLightBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$upperTotal/63',
              style: TextStyle(
                color: showBonus ? Colors.white : Colors.black,
                fontSize: AppTypography.medium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            if (showBonus)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '+35',
                  style: TextStyle(
                    color: AppTheme.accentOrange,
                    fontSize: AppTypography.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A circular progress indicator variant for the bonus.
class BonusProgressCircle extends StatelessWidget {
  /// The current upper section total score.
  final int upperTotal;

  /// Creates a circular [BonusProgress].
  const BonusProgressCircle({super.key, required this.upperTotal});

  @override
  Widget build(BuildContext context) {
    final progress = (upperTotal / 63).clamp(0.0, 1.0);
    final showBonus = upperTotal >= 63;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: AppTheme.scoreBoxLightBlue,
            valueColor: AlwaysStoppedAnimation<Color>(
              showBonus ? AppTheme.accentOrange : AppTheme.primaryLight,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$upperTotal',
              style: TextStyle(
                color: showBonus
                    ? AppTheme.accentOrange
                    : AppTheme.primaryLight,
                fontSize: AppTypography.large,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showBonus)
              const Text(
                '+35',
                style: TextStyle(
                  color: AppTheme.accentOrange,
                  fontSize: AppTypography.small,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
