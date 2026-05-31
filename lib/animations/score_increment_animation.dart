import 'package:flutter/material.dart';

/// Animates a score value change with a pop-scale effect and color flash.
///
/// When [score] changes, the widget plays a brief animation:
/// - Scale pops from 1.0 → 1.3 → 1.0
/// - Color flashes green for positive changes, red for negative
/// - Duration is approximately 300ms
class AnimatedScoreWidget extends StatefulWidget {
  /// The current score value to display.
  final int score;

  /// The previous score value (used to determine change direction).
  final int previousScore;

  /// Custom text style for the score display.
  final TextStyle? textStyle;

  /// Duration of the pop animation.
  static const Duration duration = Duration(milliseconds: 300);

  const AnimatedScoreWidget({
    super.key,
    required this.score,
    this.previousScore = 0,
    this.textStyle,
  });

  @override
  State<AnimatedScoreWidget> createState() => _AnimatedScoreWidgetState();
}

class _AnimatedScoreWidgetState extends State<AnimatedScoreWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimatedScoreWidget.duration,
    );

    // Scale pop: 1.0 → 1.3 → 1.0
    _scaleAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: const Interval(0.0, 0.4))),
        weight: 40.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: const Interval(0.4, 1.0))),
        weight: 60.0,
      ),
    ]).animate(_controller);

    _controller.addStatusListener(_onAnimationStatusChanged);

    // Trigger animation on first render if score differs from previous
    if (widget.score != widget.previousScore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAnimation();
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedScoreWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _controller.forward(from: 0.0);
    setState(() {
      _isAnimating = true;
    });
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _isAnimating = false;
      });
    }
  }

  Color? _getFlashColor() {
    if (!_isAnimating) return null;
    final theme = Theme.of(context);
    final change = widget.score - widget.previousScore;
    if (change > 0) {
      return theme.colorScheme.primary; // Green flash for positive
    } else if (change < 0) {
      return theme.colorScheme.error; // Red flash for negative
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Text(
            widget.score.toString(),
            style: widget.textStyle?.copyWith(color: _getFlashColor()),
          ),
        );
      },
    );
  }
}

/// Animates a score increment with a counting effect.
///
/// Uses [TweenAnimationBuilder] to smoothly animate the numeric value
/// from [from] to [to] over the specified duration.
class ScoreIncrementAnimation extends StatelessWidget {
  /// The starting score value.
  final int from;

  /// The target score value.
  final int to;

  /// Duration of the counting animation.
  final Duration duration;

  /// Custom text style for the score display.
  final TextStyle? textStyle;

  /// Called when the animation completes.
  final VoidCallback? onComplete;

  const ScoreIncrementAnimation({
    super.key,
    required this.from,
    required this.to,
    this.duration = const Duration(milliseconds: 500),
    this.textStyle,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: from, end: to),
      duration: duration,
      onEnd: onComplete,
      builder: (context, value, child) {
        return Text(value.toString(), style: textStyle);
      },
    );
  }
}
