import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/animations/dice_roll_animation.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/widgets/die_widget.dart';

/// Displays a container of dice with roll animations.
///
/// Shows 5 dice or placeholders when no dice are rolled.
/// Wraps each die in [DieRollAnimation] for smooth roll effects.
/// Held dice are excluded from animation.
class DiceContainer extends ConsumerWidget {
  /// The dice values to display.
  final List<int>? diceRoll;

  /// Whether dice are currently rolling.
  final bool? isRolling;

  /// Creates a dice container.
  const DiceContainer({
    super.key,
    this.diceRoll,
    this.isRolling,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use provider state when params are null
    final gameState = ref.watch(gameStateProvider);
    final effectiveDiceRoll = diceRoll ?? gameState.diceRoll;
    final effectiveIsRolling = isRolling ?? gameState.isRolling;

    // Dice can only be held when rolled, not rolling, and rolls remain
    final canHoldDice = effectiveDiceRoll != null &&
        !effectiveIsRolling &&
        gameState.currentRollsRemaining > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final dieValue = effectiveDiceRoll?.elementAt(index);
          final isHeld = canHoldDice &&
              gameState.effectiveHeldDice[index] == true;
          final onTap = canHoldDice
              ? () {
                  final notifier =
                      ref.read(gameNotifierProvider.notifier);
                  notifier.toggleHeldDice(index);
                }
              : null;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DieRollAnimation(
              index: index,
              isRolling: effectiveIsRolling,
              isHeld: isHeld,
              child: dieValue != null
                  ? DieWidget(
                      value: dieValue,
                      isHeld: isHeld,
                      onTap: onTap,
                    )
                  : const SizedBox(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: Text(
                          '?',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }
}
