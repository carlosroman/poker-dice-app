import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/models/dice_roll.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/widgets/die_widget.dart';

/// Displays 5 dice in a horizontal row.
///
/// Watches the [gameNotifierProvider] for dice state and allows tapping
/// individual dice to toggle their held state.
class DiceContainer extends ConsumerWidget {
  /// The current dice roll to display.
  final DiceRoll? diceRoll;

  /// Whether tapping dice to toggle hold is enabled.
  final bool isInteractive;

  /// The size of each die face. Defaults to 56.
  final double dieSize;

  const DiceContainer({
    super.key,
    this.diceRoll,
    this.isInteractive = true,
    this.dieSize = 56,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(gameNotifierProvider.notifier);

    final dice = diceRoll?.dice;

    return Card(
      child: SizedBox(
        width: 5 * dieSize + 24,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List<Widget>.generate(5, (index) {
              if (dice == null || index >= dice.length) {
                return SizedBox(
                  width: dieSize,
                  height: dieSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(dieSize * 0.15),
                    ),
                  ),
                );
              }

              final die = dice[index];

              return DieWidget(
                value: die.value,
                isHeld: die.isHeld,
                size: dieSize,
                onTap: isInteractive
                    ? () => notifier.toggleDieHold(index)
                    : null,
              );
            }),
          ),
        ),
      ),
    );
  }
}
