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
          ...List.generate(playerCount, (index) {
            final isActive = index == currentPlayer;
            return Padding(
              padding: EdgeInsets.only(right: index < playerCount - 1 ? 12 : 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Player ${index + 1}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isActive
                          ? colors.onSecondaryContainer
                          : colors.onSecondaryContainer.withValues(alpha: 0.5),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 4),
                    Text(
                      'Your Turn',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
