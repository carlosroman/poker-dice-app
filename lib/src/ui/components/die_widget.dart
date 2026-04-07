import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/die.dart';
import '../theme/app_theme.dart';

/// A 3D-style die face widget for the Yatzy dice game.
///
/// Displays a die with proper dot positioning for values 1-6.
/// Supports held state with visual feedback and tap interaction.
/// Includes roll animation with shake, scale, and fade effects.
///
/// ## Features
/// - Realistic dot positioning for standard dice
/// - Held state with color change and shadow
/// - Roll animation with scale, rotation, and shake
/// - Responsive sizing based on screen width
/// - Tap interaction for holding dice
///
/// ## Dot Positioning
/// Standard dice dot patterns are used for all values:
/// - 1: Center dot
/// - 2: Diagonal corners
/// - 3: Diagonal with center
/// - 4: Four corners
/// - 5: Four corners with center
/// - 6: Two columns of three
///
/// Example:
/// ```dart
/// DieWidget(
///   die: gameBloc.state.dice[index],
///   isRolling: gameBloc.state.isRolling,
///   onTap: () => gameBloc.add(ToggleDie(index: index)),
/// )
/// ```
class DieWidget extends StatefulWidget {
  /// The die model to display.
  ///
  /// Contains the current value (1-6) and held state of the die.
  final Die die;

  /// Optional callback triggered when the die is tapped.
  ///
  /// Used to toggle the held state of the die.
  final VoidCallback? onTap;

  /// Whether to trigger roll animation.
  ///
  /// When true, plays the roll animation sequence.
  /// Set to true briefly during dice roll operations.
  final bool isRolling;

  /// The default size of the die face in pixels.
  static const double _defaultSize = 80.0;

  /// The size of each dot on the die face in pixels.
  static const double _dotSize = 16.0;

  /// Roll animation duration.
  static const Duration _rollDuration = Duration(milliseconds: 400);

  /// Creates a [DieWidget] instance.
  ///
  /// The [die] parameter must not be null.
  /// The [isRolling] parameter defaults to false.
  const DieWidget({
    super.key,
    required this.die,
    this.onTap,
    this.isRolling = false,
  });

  @override
  State<DieWidget> createState() => _DieWidgetState();
}

class _DieWidgetState extends State<DieWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DieWidget._rollDuration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.1), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _shakeAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 360.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(DieWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !_controller.isAnimating) {
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
    final size = MediaQuery.of(context).size.width > 600
        ? DieWidget._defaultSize
        : MediaQuery.of(context).size.width * 0.18;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Transform.rotate(
            angle: _rotationAnimation.value * (math.pi / 180),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(opacity: _opacityAnimation.value, child: child),
            ),
          ),
        );
      },
      child: _buildDieContent(size),
    );
  }

  Widget _buildDieContent(double size) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: _buildDecoration(),
        child: _buildDotGrid(),
      ),
    );
  }

  /// Builds the decoration for the die face.
  ///
  /// Returns different decorations based on the held state:
  /// - Held: Blue tint with glow shadow
  /// - Not held: White background with standard shadow
  ///
  /// Returns:
  /// A [BoxDecoration] configured for the die state.
  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: widget.die.held ? _getHeldColor() : AppTheme.diceFaceColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      boxShadow: widget.die.held ? _getHeldShadow() : AppTheme.shadowMedium,
      border: Border.all(
        color: widget.die.held
            ? AppTheme.diceSelectedColor
            : AppTheme.diceBorderColor,
        width: widget.die.held ? 3.0 : 1.5,
      ),
    );
  }

  /// Returns the color for held state.
  ///
  /// Returns:
  /// A semi-transparent blue color for held dice.
  Color _getHeldColor() {
    return AppTheme.diceSelectedColor.withValues(alpha: 0.1);
  }

  /// Returns the shadow for held state.
  ///
  /// Returns:
  /// A list of box shadows with glow effect for held dice.
  List<BoxShadow> _getHeldShadow() {
    return [
      BoxShadow(
        color: AppTheme.diceSelectedColor.withValues(alpha: 0.4),
        blurRadius: 12.0,
        offset: const Offset(0, 4),
      ),
      ...AppTheme.shadowMedium,
    ];
  }

  /// Builds the grid of dots based on the die value.
  ///
  /// Creates a [Stack] with positioned dots according to
  /// standard dice patterns for values 1-6.
  ///
  /// Returns:
  /// A [Stack] widget with positioned dot containers.
  Widget _buildDotGrid() {
    final dotPositions = _getDotPositions(widget.die.value);

    return Stack(
      children: dotPositions.asMap().entries.map((entry) {
        final index = entry.key;
        final position = entry.value;
        return Positioned(
          left: position.dx,
          top: position.dy,
          child: _buildDot(index),
        );
      }).toList(),
    );
  }

  /// Builds a single dot widget.
  ///
  /// Creates a circular container representing a dot on the die face.
  ///
  /// Parameters:
  /// - [index]: Unique identifier for the dot (used for key)
  ///
  /// Returns:
  /// A circular [Container] widget.
  Widget _buildDot(int index) {
    return Container(
      key: ValueKey('dot-$index'),
      width: DieWidget._dotSize,
      height: DieWidget._dotSize,
      decoration: BoxDecoration(
        color: AppTheme.diceDotColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  /// Returns the positions for dots based on die value.
  ///
  /// Calculates normalized positions (0.0 to 1.0) for each dot
  /// according to standard dice patterns.
  ///
  /// Parameters:
  /// - [value]: The die value (1-6)
  ///
  /// Returns:
  /// A list of [Offset] positions for the dots.
  ///
  /// Throws:
  /// No exceptions - invalid values return empty list.
  List<Offset> _getDotPositions(int value) {
    final positions = <Offset>[];

    switch (value) {
      case 1:
        positions.add(Offset(0.5, 0.5));
        break;
      case 2:
        positions.add(Offset(0.25, 0.25));
        positions.add(Offset(0.75, 0.75));
        break;
      case 3:
        positions.add(Offset(0.25, 0.25));
        positions.add(Offset(0.5, 0.5));
        positions.add(Offset(0.75, 0.75));
        break;
      case 4:
        positions.add(Offset(0.25, 0.25));
        positions.add(Offset(0.75, 0.25));
        positions.add(Offset(0.25, 0.75));
        positions.add(Offset(0.75, 0.75));
        break;
      case 5:
        positions.add(Offset(0.25, 0.25));
        positions.add(Offset(0.75, 0.25));
        positions.add(Offset(0.5, 0.5));
        positions.add(Offset(0.25, 0.75));
        positions.add(Offset(0.75, 0.75));
        break;
      case 6:
        positions.add(Offset(0.25, 0.25));
        positions.add(Offset(0.75, 0.25));
        positions.add(Offset(0.25, 0.5));
        positions.add(Offset(0.75, 0.5));
        positions.add(Offset(0.25, 0.75));
        positions.add(Offset(0.75, 0.75));
        break;
    }

    return positions;
  }
}
