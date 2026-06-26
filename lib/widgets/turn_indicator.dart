import 'package:flutter/material.dart';

/// Displays a pill-style indicator showing whose turn it is.
///
/// Hidden in single-player mode ([playerCount] <= 1).
class TurnIndicator extends StatelessWidget {
  const TurnIndicator({
    super.key,
    required this.playerCount,
    required this.currentPlayer,
  });

  final int playerCount;
  final int currentPlayer;

  @override
  Widget build(BuildContext context) {
    if (playerCount <= 1) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sports_esports_rounded,
            size: 20,
            color: colors.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            'Player ${currentPlayer + 1}\'s Turn',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
