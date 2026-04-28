import 'package:flutter/material.dart';

/// Animation controller for score update effects.
///
/// Provides scale/pop effects and color flash animations
/// when scores are updated.
///
/// Example usage:
/// ```dart
/// final scoreAnimation = ScoreIncrementAnimation(vsync: this);
/// scoreAnimation.animateTo(42);
/// ```
class ScoreIncrementAnimation {
  /// The animation controller for scale effect.
  final AnimationController _scaleController;

  /// The scale/pop animation.
  late final Animation<double> _scaleAnimation;

  /// Current score value.
  int _currentScore = 0;

  /// Target score value for animation.
  int _targetScore = 0;

  /// Duration of the scale animation.
  final Duration scaleDuration;

  /// Color to flash on increment.
  final Color flashColor;

  /// Creates a [ScoreIncrementAnimation] with the specified durations.
  ///
  /// [vsync] is required to provide the ticker for the animation controllers.
  ScoreIncrementAnimation({
    required TickerProvider vsync,
    this.scaleDuration = const Duration(milliseconds: 300),
    this.flashColor = const Color(0xFF4CAF50), // Green
  }) : _scaleController = AnimationController(
         duration: scaleDuration,
         vsync: vsync,
       ) {
    _initAnimations();
  }

  /// Initializes all animation curves and sequences.
  void _initAnimations() {
    // Scale animation: pop effect
    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 20),
          TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
        );
  }

  /// Animates to a new score value.
  ///
  /// [newValue] is the target score to animate to.
  void animateTo(int newValue) {
    _targetScore = newValue;

    // Start scale animation
    if (_scaleController.isAnimating) {
      _scaleController.stop();
    }
    _scaleController.forward(from: 0.0);
  }

  /// Gets the current score value.
  int get currentScore => _currentScore;

  /// Gets the target score value.
  int get targetScore => _targetScore;

  /// Gets the scale animation.
  Animation<double> get scaleAnimation => _scaleAnimation;

  /// Updates the current score without animation.
  void setCurrentScore(int value) {
    _currentScore = value;
  }

  /// Disposes all resources used by the animation.
  void dispose() {
    _scaleController.dispose();
  }
}

/// Animated score counter widget with scale and color flash effects.
///
/// Displays the score with a pop animation and optional color flash
/// when the score changes.
///
/// Example usage:
/// ```dart
/// AnimatedScoreCounter(
///   score: 100,
///   style: TextStyle(fontSize: 24, color: Colors.white),
///   flashColor: Colors.green,
/// )
/// ```
class AnimatedScoreCounter extends StatefulWidget {
  /// The current score to display.
  final int score;

  /// Optional custom text style.
  final TextStyle? style;

  /// Whether to animate scale effect.
  final bool animateScale;

  /// Whether to animate color flash.
  final bool animateColor;

  /// Color to flash on score increment.
  final Color flashColor;

  /// Creates an [AnimatedScoreCounter].
  const AnimatedScoreCounter({
    super.key,
    required this.score,
    this.style,
    this.animateScale = true,
    this.animateColor = true,
    this.flashColor = const Color(0xFF4CAF50),
  });

  @override
  State<AnimatedScoreCounter> createState() => _AnimatedScoreCounterState();
}

class _AnimatedScoreCounterState extends State<AnimatedScoreCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<Color?> _colorAnimation;
  int _previousScore = 0;

  @override
  void initState() {
    super.initState();
    _previousScore = widget.score;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 20),
        TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 50),
      ],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _colorAnimation = ColorTween(
      begin: widget.flashColor,
      end: widget.style?.color ?? Colors.white,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AnimatedScoreCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score && widget.score > _previousScore) {
      _animate();
    }
    _previousScore = widget.score;
  }

  void _animate() {
    if (widget.animateScale || widget.animateColor) {
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
    Widget content = Text(
      widget.score.toString(),
      style:
          widget.style ??
          const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
    );

    if (widget.animateScale) {
      content = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: content,
      );
    }

    if (widget.animateColor) {
      content = AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Text(
            widget.score.toString(),
            style:
                (widget.style ??
                        const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ))
                    .copyWith(color: _colorAnimation.value),
          );
        },
      );
    }

    return content;
  }
}
