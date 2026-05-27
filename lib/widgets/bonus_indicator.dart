import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/providers/game_provider.dart';

/// Displays progress toward the 63-point bonus threshold.
///
/// Shows current upper section total vs threshold (e.g., "37/63 ○")
/// and indicates whether the bonus has been awarded.
class BonusIndicator extends ConsumerWidget {
  static const int _bonusThreshold = 63;
  static const int _bonusPoints = 35;

  const BonusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final theme = Theme.of(context);

    final upperTotal = gameState.upperSectionTotal;
    final isAwarded = gameState.bonusAwarded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'BONUS +$_bonusPoints',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isAwarded
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$upperTotal/$_bonusThreshold',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isAwarded
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isAwarded ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: isAwarded
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
