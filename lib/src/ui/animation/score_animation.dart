import 'package:flutter/material.dart';
import 'package:poker_dice/src/ui/animation/animation_constants.dart';

/// A widget that displays an animated score with fade-in and slide effects.
///
/// This widget provides visual feedback when a score is updated, featuring:
/// - Fade-in effect when score appears
/// - Slide-in from the right
/// - Brief highlight animation to draw attention
///
/// Example:
/// ```dart
/// AnimatedScoreWidget(
///   score: currentScore,
///   isNewScore: scoreJustUpdated,
/// )
/// ```
class AnimatedScoreWidget extends StatefulWidget {
  /// The score value to display.
  final int? score;

  /// Whether this is a newly updated score (triggers animation).
  final bool isNewScore;

  /// Whether to display the Yatzy bonus indicator.
  final bool showBonus;

  /// Creates an [AnimatedScoreWidget].
  const AnimatedScoreWidget({
    super.key,
    this.score,
    this.isNewScore = false,
    this.showBonus = false,
  });

  @override
  State<AnimatedScoreWidget> createState() => _AnimatedScoreWidgetState();
}

class _AnimatedScoreWidgetState extends State<AnimatedScoreWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _highlightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.easeIn),
    );

    _highlightAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isNewScore) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(AnimatedScoreWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isNewScore && !oldWidget.isNewScore) {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.5, 0.0),
                end: Offset.zero,
              ).animate(_fadeAnimation),
              child: FadeTransition(opacity: _fadeAnimation, child: child),
            );
          },
          child: _ScoreBox(
            score: widget.score,
            highlightOpacity: _highlightAnimation.value,
          ),
        ),
        if (widget.showBonus)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  '+50',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// A widget displaying the score in a styled box with optional highlight.
class _ScoreBox extends StatelessWidget {
  final int? score;
  final double highlightOpacity;

  const _ScoreBox({required this.score, required this.highlightOpacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(4),
        border: highlightOpacity > 0
            ? Border.all(
                color: Colors.orange.withValues(alpha: highlightOpacity),
                width: 2 + (2 * highlightOpacity),
              )
            : null,
      ),
      child: Text(
        score?.toString() ?? '',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getBackgroundColor() {
    if (highlightOpacity > 0) {
      return Colors.orange.withValues(alpha: 0.3 + (0.3 * highlightOpacity));
    }
    return const Color(0xFF4FC3F7);
  }
}

/// A widget that animates an entire score row when selected.
///
/// This provides visual feedback when a category row is tapped for selection.
class AnimatedScoreRow extends StatefulWidget {
  /// The child widget to animate.
  final Widget child;

  /// Whether this row is currently selected.
  final bool isSelected;

  /// Animation duration.
  final Duration duration;

  /// Creates an [AnimatedScoreRow].
  const AnimatedScoreRow({
    super.key,
    required this.child,
    this.isSelected = false,
    this.duration = AnimationDurations.short,
  });

  @override
  State<AnimatedScoreRow> createState() => _AnimatedScoreRowState();
}

class _AnimatedScoreRowState extends State<AnimatedScoreRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.standard),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.standard),
    );

    if (widget.isSelected) {
      _controller.forward(from: 0.0).then((_) {
        _controller.reverse(from: 0.0);
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedScoreRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward(from: 0.0).then((_) {
        _controller.reverse(from: 0.0);
      });
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
          child: Opacity(opacity: _opacityAnimation.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}
