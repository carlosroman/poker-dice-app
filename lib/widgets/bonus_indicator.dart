import 'package:flutter/material.dart';

/// A widget that displays bonus progress for the upper section of the scorecard.
///
/// Shows the current score, target score, and a visual indicator showing
/// the bonus status with color coding:
/// - Green: Bonus awarded (score >= target)
/// - Orange/Amber: Close to bonus (score >= 50% of target)
/// - Gray: Far from bonus target
class BonusIndicator extends StatelessWidget {
  /// The current upper section score.
  final int currentScore;

  /// The target score needed for bonus (default 63).
  final int targetScore;

  /// The bonus points awarded when target is reached (default 35).
  final int bonusPoints;

  /// Whether the bonus has been awarded.
  final bool bonusAwarded;

  /// Creates a [BonusIndicator] widget.
  const BonusIndicator({
    super.key,
    required this.currentScore,
    this.targetScore = 63,
    this.bonusPoints = 35,
    this.bonusAwarded = false,
  });

  /// Determines the color based on bonus status.
  Color _getProgressColor(BuildContext context) {
    if (bonusAwarded) {
      return Theme.of(context).colorScheme.primaryContainer;
    }

    final percentage = currentScore / targetScore;
    if (percentage >= 0.8) {
      return Theme.of(context).colorScheme.primary;
    } else if (percentage >= 0.5) {
      return Theme.of(context).colorScheme.secondary;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildScoreText(context),
        const SizedBox(width: 8),
        _buildCircleIndicator(context),
      ],
    );
  }

  /// Builds the score text widget showing current/target.
  Widget _buildScoreText(BuildContext context) {
    return Text(
      '$currentScore/$targetScore',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: _getProgressColor(context),
      ),
      semanticsLabel: 'Upper section score: $currentScore out of $targetScore',
    );
  }

  /// Builds the circular indicator widget.
  Widget _buildCircleIndicator(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: _getProgressColor(context),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2,
        ),
      ),
      child: bonusAwarded
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}
