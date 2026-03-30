import 'package:flutter/material.dart';
import 'dice_dot.dart';

/// A dice widget for the Poker Dice (Yatzy) game.
///
/// Displays a dice face with traditional pips (dots) for values 1-6
/// and supports hold functionality with visual feedback.
class DiceCard extends StatefulWidget {
  /// The dice value (1-6 for traditional dice faces).
  /// Null means the dice is unrolled/blank.
  final int? value;

  /// Whether the dice is held.
  final bool isHeld;

  /// Callback for tap to toggle hold.
  final VoidCallback? onTap;

  /// Creates a [DiceCard] widget.
  const DiceCard({
    super.key,
    required this.value,
    required this.isHeld,
    this.onTap,
  });

  @override
  State<DiceCard> createState() => _DiceCardState();
}

class _DiceCardState extends State<DiceCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Roll animation controller and animations
  late AnimationController _rollController;
  late Animation<double> _rollXAnimation;
  late Animation<double> _rollRotationAnimation;

  // Held state animation
  late AnimationController _heldController;
  late Animation<double> _heldOpacityAnimation;

  static const double _cardWidth = 70.0;
  static const double _cardHeight = 70.0;
  static const double _borderWidth = 2.0;
  static const Color _diceBackgroundColor = Colors.white;
  static const Color _heldBorderColor = Color(0xFFFF6F00);
  static const Color _unrolledDiceBackgroundColor = Colors.grey;
  static const Color _heldOverlayColor = Color(0xFFBDBDBD);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Roll animation setup
    _rollController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    // Shake animation (left-right movement)
    _rollXAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -5.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 5.0, end: -3.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -3.0, end: 3.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 3.0, end: -1.5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -1.5, end: 1.5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _rollController, curve: Curves.easeInOut),
        );

    // Rotation animation (slight tilt during roll)
    _rollRotationAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 8.0, end: -5.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 5.0, end: -3.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -3.0, end: 3.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 3.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _rollController, curve: Curves.easeInOut),
        );

    _animationController.forward();

    // Initialize held state animation
    _heldController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _heldOpacityAnimation = Tween<double>(begin: 1.0, end: 0.75).animate(
      CurvedAnimation(parent: _heldController, curve: Curves.easeInOut),
    );

    // Start held animation if initially held
    if (widget.isHeld) {
      _heldController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(DiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger roll animation when value changes (and dice was not held before)
    if (oldWidget.value != widget.value && !oldWidget.isHeld) {
      _triggerRollAnimation();
    }
    // Trigger held animation when held state changes
    if (oldWidget.isHeld != widget.isHeld) {
      if (widget.isHeld) {
        _heldController.forward();
      } else {
        _heldController.reverse();
      }
    }
  }

  void _triggerRollAnimation() {
    _rollController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rollController.dispose();
    _heldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rollController,
      builder: (context, child) {
        return AnimatedScale(
          scale: _scaleAnimation.value,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _opacityAnimation.value,
            duration: const Duration(milliseconds: 200),
            child: Transform.translate(
              offset: Offset(_rollXAnimation.value, 0),
              child: Transform.rotate(
                angle: _rollRotationAnimation.value * (3.14159 / 180),
                child: child,
              ),
            ),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _heldController,
        builder: (context, child) {
          return AnimatedOpacity(
            opacity: widget.isHeld ? _heldOpacityAnimation.value : 1.0,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              key: ValueKey('dice-${widget.value}-held-${widget.isHeld}'),
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: _cardWidth,
                height: _cardHeight,
                decoration: BoxDecoration(
                  color: widget.value != null
                      ? _diceBackgroundColor
                      : _unrolledDiceBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  border: Border.all(
                    color: widget.isHeld
                        ? _heldBorderColor.withOpacity(0.6)
                        : widget.value != null
                        ? const Color(0xFFE0E0E0)
                        : Colors.grey[400]!,
                    width: _borderWidth,
                  ),
                  boxShadow: widget.value != null
                      ? const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    widget.value != null
                        ? DiceDot(
                            value: widget.value!,
                            size: _cardWidth * 0.85,
                            pipColor: Colors.black,
                            showBackground: false,
                          )
                        : const Center(
                            child: Icon(
                              Icons.remove,
                              color: Colors.grey,
                              size: 32.0,
                            ),
                          ),
                    // Grey overlay when held
                    if (widget.isHeld)
                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: _heldOpacityAnimation.value,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                              color: _heldOverlayColor.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
