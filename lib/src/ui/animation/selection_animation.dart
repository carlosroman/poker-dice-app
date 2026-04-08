import 'package:flutter/material.dart';
import 'package:poker_dice/src/ui/animation/animation_constants.dart';

/// A widget that provides visual feedback when a category is selected.
///
/// This widget wraps any child and adds:
/// - Scale effect when tapped (shrinks briefly)
/// - Ripple effect using InkWell
/// - Optional border highlight
///
/// Example:
/// ```dart
/// AnimatedCategorySelection(
///   isSelected: isCategorySelected,
///   onTap: () => _selectCategory(category),
///   child: ScoreRow(...),
/// )
/// ```
class AnimatedCategorySelection extends StatefulWidget {
  /// The child widget to wrap with selection feedback.
  final Widget child;

  /// Callback when the widget is tapped.
  final VoidCallback? onTap;

  /// Whether this category is currently selected.
  final bool isSelected;

  /// Whether to show a highlight border.
  final bool showHighlight;

  /// Animation duration.
  final Duration duration;

  /// Creates an [AnimatedCategorySelection].
  const AnimatedCategorySelection({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.showHighlight = false,
    this.duration = AnimationDurations.short,
  });

  @override
  State<AnimatedCategorySelection> createState() =>
      _AnimatedCategorySelectionState();
}

class _AnimatedCategorySelectionState extends State<AnimatedCategorySelection>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: AnimationCurves.easeOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: AnimationCurves.easeOut,
      ),
    );

    if (widget.isSelected) {
      _triggerSelectionAnimation();
    }
  }

  @override
  void didUpdateWidget(AnimatedCategorySelection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected && !oldWidget.isSelected) {
      _triggerSelectionAnimation();
    }
  }

  void _triggerSelectionAnimation() {
    _scaleController.forward(from: 0.0).then((_) {
      _scaleController.reverse(from: 0.0);
    });
    _rippleController.forward(from: 0.0).then((_) {
      _rippleController.reverse(from: 0.0);
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _rippleController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: widget.showHighlight || _rippleAnimation.value > 0
                ? Border.all(
                    color: Colors.orange.withValues(
                      alpha: 0.5 + (_rippleAnimation.value * 0.5),
                    ),
                    width: 2 + (_rippleAnimation.value * 2),
                  )
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: _buildInteractiveChild(),
    );
  }

  Widget _buildInteractiveChild() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(4),
        child: widget.child,
      ),
    );
  }
}

/// A widget that displays a ripple effect on tap.
///
/// This provides immediate visual feedback when a category row is tapped.
class RippleEffect extends StatefulWidget {
  /// The child widget to wrap.
  final Widget child;

  /// Callback when the widget is tapped.
  final VoidCallback? onTap;

  /// Color of the ripple effect.
  final Color rippleColor;

  /// Duration of the ripple animation.
  final Duration duration;

  /// Creates a [RippleEffect].
  const RippleEffect({
    super.key,
    required this.child,
    this.onTap,
    this.rippleColor = Colors.orange,
    this.duration = AnimationDurations.short,
  });

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.easeOut),
    );
  }

  void _triggerRipple() {
    _controller.forward(from: 0.0).then((_) {
      _controller.reverse(from: 0.0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _triggerRipple();
        widget.onTap?.call();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return IgnorePointer(
                child: CustomPaint(
                  painter: _RipplePainter(
                    progress: _animation.value,
                    color: widget.rippleColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the ripple effect.
class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width / 2) * 1.5;
    final radius = maxRadius * progress;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.3 * (1 - progress))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// A widget that animates the selection state of a category row.
///
/// This provides a smooth transition when a category is selected/deselected.
class AnimatedCategoryRow extends StatefulWidget {
  /// The child widget to animate.
  final Widget child;

  /// Whether this row is selected.
  final bool isSelected;

  /// Background color when selected.
  final Color selectedColor;

  /// Background color when not selected.
  final Color unselectedColor;

  /// Animation duration.
  final Duration duration;

  /// Creates an [AnimatedCategoryRow].
  const AnimatedCategoryRow({
    super.key,
    required this.child,
    this.isSelected = false,
    this.selectedColor = Colors.orange,
    this.unselectedColor = Colors.transparent,
    this.duration = AnimationDurations.short,
  });

  @override
  State<AnimatedCategoryRow> createState() => _AnimatedCategoryRowState();
}

class _AnimatedCategoryRowState extends State<AnimatedCategoryRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _colorAnimation =
        ColorTween(
          begin: widget.unselectedColor,
          end: widget.selectedColor,
        ).animate(
          CurvedAnimation(parent: _controller, curve: AnimationCurves.standard),
        );

    if (widget.isSelected) {
      _controller.forward(from: 0.0);
    } else {
      _controller.reverse(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(AnimatedCategoryRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse(from: 0.0);
      }
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
        return Container(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
