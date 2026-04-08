import 'package:flutter/material.dart';
import 'package:poker_dice/src/ui/animation/animation_constants.dart';

/// A widget that displays an animated die with scale and fade effects.
///
/// This widget animates when the die value changes, providing visual feedback
/// for dice roll actions. The animation consists of:
/// - Scale effect: Die shrinks slightly then expands back
/// - Fade effect: Brief opacity change during roll
///
/// Example:
/// ```dart
/// AnimatedDieWidget(
///   value: dieValue,
///   isHeld: isHeld,
///   onRollStarted: () => _gameBloc.rollDice(),
/// )
/// ```
class AnimatedDieWidget extends StatefulWidget {
  /// The value of the die (1-6).
  final int value;

  /// Whether the die is currently held/selected.
  final bool isHeld;

  /// Optional callback when the die is tapped.
  final VoidCallback? onTap;

  /// Whether to trigger the roll animation.
  final bool triggerAnimation;

  /// Creates an [AnimatedDieWidget].
  ///
  /// The [value] must be between 1 and 6.
  /// The [isHeld] defaults to false.
  /// The [triggerAnimation] defaults to false.
  const AnimatedDieWidget({
    super.key,
    required this.value,
    this.isHeld = false,
    this.onTap,
    this.triggerAnimation = false,
  }) : assert(value >= 1 && value <= 6, 'Die value must be between 1 and 6');

  @override
  State<AnimatedDieWidget> createState() => _AnimatedDieWidgetState();
}

class _AnimatedDieWidgetState extends State<AnimatedDieWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.long,
      vsync: this,
    );

    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.85),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.85, end: 1.0),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: AnimationCurves.standard),
        );

    _fadeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.5),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.5, end: 1.0),
            weight: 70,
          ),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: AnimationCurves.easeOut),
        );
  }

  @override
  void didUpdateWidget(AnimatedDieWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animation when triggerAnimation changes from false to true
    if (!oldWidget.triggerAnimation && widget.triggerAnimation) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: _DieContent(
        value: widget.value,
        isHeld: widget.isHeld,
        onTap: widget.onTap,
      ),
    );
  }
}

/// Internal widget that renders the actual die content.
class _DieContent extends StatelessWidget {
  final int value;
  final bool isHeld;
  final VoidCallback? onTap;

  const _DieContent({required this.value, required this.isHeld, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isHeld ? Border.all(color: Colors.orange, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _DieDots(value: value),
      ),
    );
  }
}

/// Internal widget that renders the dots on a die face.
class _DieDots extends StatelessWidget {
  final int value;

  const _DieDots({required this.value});

  @override
  Widget build(BuildContext context) {
    final positions = _getDotPositions(value);

    return Stack(
      children: positions
          .map(
            (offset) => Positioned(
              left: offset.dx,
              top: offset.dy,
              child: const _DieDot(),
            ),
          )
          .toList(),
    );
  }

  /// Returns the positions of dots for a given die value.
  List<Offset> _getDotPositions(int value) {
    const center = 30.0;
    const corner = 15.0;
    const mid = 45.0;

    switch (value) {
      case 1:
        return [Offset(center, center)];
      case 2:
        return [Offset(corner, corner), Offset(mid, mid)];
      case 3:
        return [
          Offset(corner, corner),
          Offset(center, center),
          Offset(mid, mid),
        ];
      case 4:
        return [
          Offset(corner, corner),
          Offset(mid, corner),
          Offset(corner, mid),
          Offset(mid, mid),
        ];
      case 5:
        return [
          Offset(corner, corner),
          Offset(mid, corner),
          Offset(center, center),
          Offset(corner, mid),
          Offset(mid, mid),
        ];
      case 6:
        return [
          Offset(corner, corner),
          Offset(mid, corner),
          Offset(corner, center),
          Offset(mid, center),
          Offset(corner, mid),
          Offset(mid, mid),
        ];
      default:
        return [];
    }
  }
}

/// A small black dot representing a pip on a die face.
class _DieDot extends StatelessWidget {
  const _DieDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}
