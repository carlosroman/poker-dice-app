import 'package:flutter/material.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/widgets/dice_face.dart';

/// An animated dice widget that displays a [DiceFace] with a tumble animation.
///
/// Extends the functionality of a static dice display by adding a rotation
/// and scale animation triggered programmatically via [AnimatedDiceState.animate].
///
/// The animation consists of:
/// - **Tumble phase**: The die rotates through multiple full turns while
///   shrinking slightly.
/// - **Snap phase**: The die bounces back to its normal size, simulating
///   the die landing on a table.
///
/// Total duration is 400 ms. Each die animates independently.
///
/// ### Usage
///
/// Hold a [GlobalKey] to the [AnimatedDiceState] and call [animate] when
/// a roll occurs:
///
/// ```dart
/// final _keys = List.generate(5, (i) => GlobalKey<AnimatedDiceState>());
///
/// // In build:
/// AnimatedDice(
///   key: _keys[index],
///   dice: dice[index],
///   size: 56.0,
///   onTap: () => notifier.toggleHold(index),
/// )
///
/// // On roll:
/// _keys[index].currentState?.animate();
/// ```
class AnimatedDice extends StatefulWidget {
  /// The dice data to display.
  final Dice dice;

  /// Called when the dice is tapped.
  final VoidCallback? onTap;

  /// The overall size (width and height) of the dice.
  ///
  /// Defaults to 48.0.
  final double size;

  /// The color used for the held-state border glow.
  ///
  /// Defaults to [Colors.amber].
  final Color heldColor;

  /// The width of the held-state border.
  ///
  /// Defaults to 3.0.
  final double heldBorderWidth;

  /// The background color of the dice face.
  ///
  /// Defaults to [ColorScheme.surface] from the current theme.
  final Color? backgroundColor;

  /// Called when the tumble animation completes.
  final VoidCallback? onAnimationComplete;

  /// Creates an [AnimatedDice].
  const AnimatedDice({
    super.key,
    required this.dice,
    this.onTap,
    this.size = 48.0,
    this.heldColor = Colors.amber,
    this.heldBorderWidth = 3.0,
    this.backgroundColor,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedDice> createState() => AnimatedDiceState();
}

/// State for [AnimatedDice] that manages the tumble animation.
///
/// Exposes [animate] to trigger the tumble animation from the parent.
class AnimatedDiceState extends State<AnimatedDice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..addStatusListener(_onAnimationStatusChanged);

    // Rotation: 2 full turns (720°) during the animation.
    _rotationAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ).drive(Tween<double>(begin: 0, end: 2.0));

    // Scale: shrink to 0.8 then elastic bounce back to 1.0.
    _scaleAnimation = _controller.drive(_BounceScaleTween(minScale: 0.8));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Triggers the tumble animation.
  ///
  /// If the animation is already running, it is restarted.
  /// When the animation completes, [widget.onAnimationComplete] is invoked.
  void animate() {
    _controller.forward(from: 0);
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        widget.onAnimationComplete != null) {
      widget.onAnimationComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surface;
    final borderRadius = BorderRadius.circular(widget.size / 6);

    final child = GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
          border: widget.dice.isHeld
              ? Border.all(
                  color: widget.heldColor,
                  width: widget.heldBorderWidth,
                )
              : null,
        ),
        child: DiceFace(value: widget.dice.value, size: widget.size),
      ),
    );

    return Semantics(
      label:
          'Die showing ${widget.dice.value}${widget.dice.isHeld ? ', held' : ''}',
      button: widget.onTap != null,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: child),
      ),
    );
  }
}

/// A custom [Animatable] that scales from 1.0 down to [minScale]
/// and bounces back to 1.0 using an elastic-out curve.
///
/// - First 70% of the animation: ease-in shrink to [minScale].
/// - Last 30% of the animation: elastic bounce back to 1.0.
class _BounceScaleTween extends Animatable<double> {
  final double minScale;

  const _BounceScaleTween({required this.minScale});

  @override
  double transform(double t) {
    // Clamp to [0, 1] to avoid floating-point precision issues with curves.
    final clampedT = t.clamp(0.0, 1.0);
    if (clampedT <= 0.7) {
      final localT = (clampedT / 0.7).clamp(0.0, 1.0);
      return 1.0 - (1.0 - minScale) * Curves.easeIn.transform(localT);
    } else {
      final localT = ((clampedT - 0.7) / 0.3).clamp(0.0, 1.0);
      final bounce = Curves.elasticOut.transform(localT);
      return minScale + (1.0 - minScale) * bounce;
    }
  }

  // Uses default Animatable.animate implementation.
}
