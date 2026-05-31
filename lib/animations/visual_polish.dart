import 'package:flutter/material.dart';

/// A card widget with enhanced visual effects including:
/// - Subtle shadow that intensifies on hover/press
/// - Smooth border highlight animation
/// - Optional shimmer overlay for loading states
///
/// Follows Material 3 design principles with adaptive theming.
class EnhancedCard extends StatefulWidget {
  /// The content to display inside the card.
  final Widget child;

  /// The border radius for the card.
  final BorderRadiusGeometry borderRadius;

  /// Whether to enable hover effects (desktop/web only).
  final bool enableHover;

  /// Whether to enable press effects.
  final bool enablePress;

  /// The elevation of the card in its default state.
  final double elevation;

  /// The elevation of the card when hovered or pressed.
  final double elevatedElevation;

  /// Duration for elevation and border animations.
  static const Duration animationDuration = Duration(milliseconds: 200);

  const EnhancedCard({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.enableHover = true,
    this.enablePress = true,
    this.elevation = 2,
    this.elevatedElevation = 4,
  });

  @override
  State<EnhancedCard> createState() => _EnhancedCardState();
}

class _EnhancedCardState extends State<EnhancedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<double> _borderOpacityAnimation;

  bool _isInteractive = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: EnhancedCard.animationDuration,
    );

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevatedElevation,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _borderOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() {
    if (widget.enableHover && mounted) {
      setState(() => _isInteractive = true);
      _controller.forward();
    }
  }

  void _onExit() {
    if (widget.enableHover && mounted && _isInteractive) {
      setState(() => _isInteractive = false);
      _controller.reverse();
    }
  }

  void _onDown() {
    if (widget.enablePress && mounted) {
      _controller.forward();
    }
  }

  void _onUp() {
    if (widget.enablePress && mounted) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _onEnter(),
          onExit: (_) => _onExit(),
          child: GestureDetector(
            onTapDown: (_) => _onDown(),
            onTapUp: (_) => _onUp(),
            onTapCancel: _onUp,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                color: theme.colorScheme.surface,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(
                    _borderOpacityAnimation.value,
                  ),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: _elevationAnimation.value * 2,
                    offset: Offset(0, _elevationAnimation.value),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A button widget with a pulsing glow effect around its border.
///
/// The glow pulses continuously using a smooth opacity and scale animation.
/// Ideal for highlighting primary actions or featured content.
class GlowingButton extends StatefulWidget {
  /// The content to display inside the button.
  final Widget child;

  /// The callback when the button is tapped.
  final VoidCallback? onTap;

  /// The color of the glow effect.
  final Color glowColor;

  /// The border radius for the button.
  final BorderRadiusGeometry borderRadius;

  /// The width of the glow stroke.
  final double glowWidth;

  /// Duration of one complete glow pulse cycle.
  static const Duration pulseDuration = Duration(milliseconds: 1500);

  const GlowingButton({
    super.key,
    required this.child,
    this.onTap,
    this.glowColor = const Color(0xFF1B5E20),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.glowWidth = 2.0,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: GlowingButton.pulseDuration,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withOpacity(_opacityAnimation.value),
                  blurRadius: widget.glowWidth * 4,
                  spreadRadius: widget.glowWidth,
                ),
              ],
            ),
            child: widget.onTap != null
                ? GestureDetector(
                    onTap: widget.onTap,
                    child: widget.child,
                  )
                : widget.child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A shimmer effect widget that simulates loading content.
///
/// Displays a pulsing gradient animation across the widget area,
/// commonly used as a placeholder while content is loading.
class ShimmerEffect extends StatefulWidget {
  /// The child widget to apply the shimmer effect to.
  final Widget child;

  /// The base color of the shimmer.
  final Color baseColor;

  /// The highlight color of the shimmer.
  final Color highlightColor;

  /// Duration for one shimmer sweep cycle.
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFFAFAFA),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ShimmerEffect.shimmerDuration,
    )..repeat();

    // Animate from -1.0 to 2.0 to sweep across the widget
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
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
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            widget.baseColor,
            BlendMode.srcATop,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const <double>[0.0, 0.5, 1.0],
                colors: <Color>[
                  widget.baseColor,
                  widget.highlightColor,
                  widget.baseColor,
                ],
                transform: _SlidingGradientTransform(
                  slidePercent: _shimmerAnimation.value,
                ),
              ),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A gradient transform that slides the gradient based on a percentage value.
class _SlidingGradientTransform extends GradientTransform {
  /// The percentage to slide the gradient (-1.0 to 2.0).
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// A container widget with smooth elevation animation.
///
/// The container animates its elevation and shadow when [isElevated] changes,
/// creating a subtle depth effect that responds to user interaction.
class ElevatedContainer extends StatefulWidget {
  /// The content to display inside the container.
  final Widget child;

  /// Whether the container should be in the elevated state.
  final bool isElevated;

  /// The border radius for the container.
  final BorderRadiusGeometry borderRadius;

  /// The base elevation value.
  final double baseElevation;

  /// The elevated elevation value.
  final double elevatedElevation;

  /// Duration for the elevation animation.
  static const Duration elevationDuration = Duration(milliseconds: 300);

  const ElevatedContainer({
    super.key,
    required this.child,
    this.isElevated = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.baseElevation = 2,
    this.elevatedElevation = 8,
  });

  @override
  State<ElevatedContainer> createState() => _ElevatedContainerState();
}

class _ElevatedContainerState extends State<ElevatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<double> _shadowOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ElevatedContainer.elevationDuration,
    );

    _elevationAnimation = Tween<double>(
      begin: widget.baseElevation,
      end: widget.elevatedElevation,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _shadowOpacityAnimation = Tween<double>(
      begin: 0.08,
      end: 0.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isElevated) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ElevatedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isElevated != oldWidget.isElevated) {
      if (widget.isElevated) {
        _controller.forward();
      } else {
        _controller.reverse();
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
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_shadowOpacityAnimation.value),
                blurRadius: _elevationAnimation.value * 2,
                offset: Offset(0, _elevationAnimation.value),
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
