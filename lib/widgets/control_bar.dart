import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/providers/game_provider.dart';

/// Control bar with Roll and Play buttons.
///
/// Layout: [ROLL 2] [PLAY]
/// - Roll button shows remaining rolls and is disabled at 0
/// - Play button scores the selected category
class ControlBar extends ConsumerWidget {
  const ControlBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.watch(gameNotifierProvider.notifier);
    final theme = Theme.of(context);

    final canRoll = gameState.currentRollsRemaining > 0 && !gameState.isGameOver;
    final canScore = gameState.selectedCategory != null && gameState.diceRoll != null && !gameState.isGameOver;
    final rollsRemaining = gameState.currentRollsRemaining;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: canRoll ? notifier.rollDice : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.casino, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'ROLL $rollsRemaining',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: canScore
                  ? () => notifier.scoreCategory(gameState.selectedCategory ?? '')
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'PLAY',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
