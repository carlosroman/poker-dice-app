import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';

/// ControlBar widget provides game control buttons for rolling dice and playing.
///
/// Displays two main buttons:
/// - Roll button: Shows remaining rolls count, disabled when 0
/// - Play button: For selecting highlighted category
///
/// This widget can consume Riverpod state OR accept explicit parameters.
class ControlBar extends ConsumerWidget {
  /// Number of rolls remaining (0-3).
  ///
  /// If null, reads from gameProvider.
  final int? remainingRolls;

  /// Callback when roll button is pressed.
  ///
  /// If null, calls gameProvider's rollDice.
  final VoidCallback? onRollPressed;

  /// Callback when play button is pressed.
  ///
  /// If null, calls gameProvider's scoreCategory.
  final VoidCallback? onPlayPressed;

  /// Whether the play button is enabled.
  ///
  /// If null, calculated from gameProvider state.
  final bool? isPlayEnabled;

  const ControlBar({
    super.key,
    this.remainingRolls,
    this.onRollPressed,
    this.onPlayPressed,
    this.isPlayEnabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useRiverpod =
        remainingRolls == null &&
        onRollPressed == null &&
        onPlayPressed == null &&
        isPlayEnabled == null;

    final gameState = useRiverpod ? ref.watch(gameProvider) : null;
    final gameNotifier = useRiverpod ? ref.read(gameProvider.notifier) : null;

    final rolls = remainingRolls ?? (gameState?.remainingRolls ?? 0);
    final isRollEnabled = rolls > 0;

    final playEnabled =
        isPlayEnabled ??
        ((gameState?.selectedCategory != null) &&
            !(gameState?.scores.containsKey(gameState.selectedCategory) ??
                false));

    // Determine roll button callback
    VoidCallback? rollCallback;
    if (onRollPressed != null) {
      rollCallback = isRollEnabled ? onRollPressed : null;
    } else if (gameNotifier != null) {
      rollCallback = isRollEnabled ? () => gameNotifier.rollDice() : null;
    }

    // Determine play button callback
    VoidCallback? playCallback;
    if (onPlayPressed != null) {
      playCallback = playEnabled ? onPlayPressed : null;
    } else if (gameNotifier != null && gameState != null) {
      playCallback = playEnabled && gameState.selectedCategory != null
          ? () => gameNotifier.scoreCategory(gameState.selectedCategory!)
          : null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: _RollButton(remainingRolls: rolls, onPressed: rollCallback),
          ),
          const SizedBox(width: 16.0),
          Expanded(child: _PlayButton(onPressed: playCallback)),
        ],
      ),
    );
  }
}

/// Private widget for the Roll button with animated remaining rolls count.
class _RollButton extends StatelessWidget {
  final int remainingRolls;
  final VoidCallback? onPressed;

  const _RollButton({required this.remainingRolls, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled
            ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
            : theme.colorScheme.primary,
        foregroundColor: isDisabled
            ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
            : theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: Text(
          'ROLL $remainingRolls',
          key: ValueKey<int>(remainingRolls),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Private widget for the Play button.
class _PlayButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _PlayButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled
            ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
            : theme.colorScheme.secondary,
        foregroundColor: isDisabled
            ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
            : theme.colorScheme.onSecondary,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: Text(
          'PLAY',
          key: const ValueKey<String>('play'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
