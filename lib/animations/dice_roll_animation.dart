import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';

/// Animates a single die during a roll with rotation and scale bounce.
///
/// The animation runs for [DieRollAnimation.duration] and uses
/// [Curves.easeInOut] for natural motion. When [isRolling] changes from
/// false to true, the animation restarts.
class DieRollAnimation extends StatefulWidget {
  /// The index of this die within the roll (0-4), used for stagger delay.
  final int index;

  /// Whether the die is currently rolling.
  final bool isRolling;

  /// The die widget to animate.
  final Widget child;

  /// Duration of the roll animation.
  static const Duration duration = Duration(milliseconds: 500);

  /// Delay between each die starting its animation (stagger effect).
  static const Duration staggerDelay = Duration(milliseconds: 100);

  const DieRollAnimation({
    super.key,
    required this.index,
    required this.isRolling,
    required this.child,
  });

  @override
  State<DieRollAnimation> createState() => _DieRollAnimationState();
}

class _DieRollAnimationState extends State<DieRollAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  Timer? _staggerTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DieRollAnimation.duration,
    );

    // Full 360-degree rotation (in radians)
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: pi * 2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Scale bounce: start at 0.8, overshoot to 1.15, settle at 1.0
    _scaleAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.0, end: 0.8)
              .chain(CurveTween(curve: const Interval(0.0, 0.3))),
          weight: 30.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.8, end: 1.15)
              .chain(CurveTween(curve: const Interval(0.3, 0.7))),
          weight: 40.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.15, end: 1.0)
              .chain(CurveTween(curve: const Interval(0.7, 1.0))),
          weight: 30.0,
        ),
      ],
    ).animate(_controller);

    // Opacity flash: slight fade during roll, full opacity at end
    _opacityAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.0, end: 0.4)
              .chain(CurveTween(curve: const Interval(0.0, 0.2))),
          weight: 20.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.4, end: 1.0)
              .chain(CurveTween(curve: const Interval(0.2, 1.0))),
          weight: 80.0,
        ),
      ],
    ).animate(_controller);

    _controller.addStatusListener(_onAnimationStatusChanged);
  }

  @override
  void didUpdateWidget(DieRollAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _controller.removeStatusListener(_onAnimationStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _staggerTimer?.cancel();
    final delay = Duration(
      milliseconds: widget.index * DieRollAnimation.staggerDelay.inMilliseconds,
    );
    _staggerTimer = Timer(delay, () {
      if (mounted) {
        _controller.forward(from: 0.0);
      }
    });
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {}); // Trigger rebuild to show final state
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Animates a group of dice with staggered roll animations.
///
/// Wraps each die in a [DieRollAnimation] and applies staggered timing
/// based on each die's index.
class DiceRollAnimation extends StatelessWidget {
  /// Whether the dice are currently rolling.
  final bool isRolling;

  /// The list of die widgets to animate.
  final List<Widget> dice;

  const DiceRollAnimation({
    super.key,
    required this.isRolling,
    required this.dice,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List<Widget>.generate(dice.length, (index) {
        return DieRollAnimation(
          index: index,
          isRolling: isRolling,
          child: dice[index],
        );
      }),
    );
  }
}
