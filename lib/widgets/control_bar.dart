import 'package:flutter/material.dart';

/// ControlBar widget provides game control buttons for rolling dice and playing.
///
/// Displays two main buttons:
/// - Roll button: Shows remaining rolls count, disabled when 0
/// - Play button: For selecting highlighted category
class ControlBar extends StatelessWidget {
  /// Number of rolls remaining (0-3)
  final int remainingRolls;

  /// Callback when roll button is pressed
  final VoidCallback? onRollPressed;

  /// Callback when play button is pressed
  final VoidCallback? onPlayPressed;

  /// Whether the play button is enabled
  final bool isPlayEnabled;

  /// Creates a ControlBar widget.
  const ControlBar({
    super.key,
    required this.remainingRolls,
    this.onRollPressed,
    this.onPlayPressed,
    this.isPlayEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRollEnabled = remainingRolls > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: _RollButton(
              remainingRolls: remainingRolls,
              onPressed: isRollEnabled ? onRollPressed : null,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: _PlayButton(onPressed: isPlayEnabled ? onPlayPressed : null),
          ),
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
