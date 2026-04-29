import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';

/// ControlBar widget provides game control buttons for rolling dice and playing.
///
/// Displays two main buttons:
/// - Roll button: Shows remaining rolls count, disabled when 0
/// - Play button: For selecting highlighted category
///
/// Includes button press animations and ripple effects.
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

  /// Game notifier for Riverpod-based callbacks.
  ///
  /// When provided, used to create roll/play callbacks if explicit
  /// onRollPressed/onPlayPressed are not provided.
  final GameNotifier? gameNotifier;

  const ControlBar({
    super.key,
    this.remainingRolls,
    this.onRollPressed,
    this.onPlayPressed,
    this.isPlayEnabled,
    this.gameNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useRiverpod =
        remainingRolls == null &&
        onRollPressed == null &&
        onPlayPressed == null &&
        isPlayEnabled == null;

    final gameState = useRiverpod ? ref.watch(gameProvider) : null;
    // Use provided gameNotifier, or read from Riverpod if in full Riverpod mode
    final effectiveGameNotifier =
        gameNotifier ?? (useRiverpod ? ref.read(gameProvider.notifier) : null);

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
    } else if (effectiveGameNotifier != null) {
      rollCallback = isRollEnabled
          ? () => effectiveGameNotifier.rollDice()
          : null;
    }

    // Determine play button callback
    VoidCallback? playCallback;
    if (onPlayPressed != null) {
      playCallback = playEnabled ? onPlayPressed : null;
    } else if (effectiveGameNotifier != null && gameState != null) {
      playCallback = playEnabled && gameState.selectedCategory != null
          ? () =>
                effectiveGameNotifier.scoreCategory(gameState.selectedCategory!)
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

/// Private widget for the Roll button with animated remaining rolls count
/// and button press animation.
class _RollButton extends StatefulWidget {
  final int remainingRolls;
  final VoidCallback? onPressed;

  const _RollButton({required this.remainingRolls, this.onPressed});

  @override
  State<_RollButton> createState() => _RollButtonState();
}

class _RollButtonState extends State<_RollButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: InkResponse(
          onTap: widget.onPressed,
          radius: 50,
          containedInkWell: true,
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              color: isDisabled
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
                  : theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color:
                      (isDisabled
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.primary)
                          .withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
                'ROLL ${widget.remainingRolls}',
                key: ValueKey<int>(widget.remainingRolls),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDisabled
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                      : theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Private widget for the Play button with press animation.
class _PlayButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const _PlayButton({this.onPressed});

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: InkResponse(
          onTap: widget.onPressed,
          radius: 50,
          containedInkWell: true,
          highlightColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              color: isDisabled
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
                  : theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color:
                      (isDisabled
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.secondary)
                          .withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
                  color: isDisabled
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                      : theme.colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
