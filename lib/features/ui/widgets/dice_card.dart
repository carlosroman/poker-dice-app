import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/dice_faces.dart';

/// A card-style dice widget for the Poker Dice game.
///
/// Displays a dice face with card-style values (9, 10, J, Q, K, A)
/// and supports hold functionality with visual feedback.
class DiceCard extends StatefulWidget {
  /// The dice value (index 0-5 for card faces: 9, 10, J, Q, K, A).
  final int value;

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

class _DiceCardState extends State<DiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  static const double _cardWidth = 60.0;
  static const double _cardHeight = 84.0;
  static const double _borderWidth = 2.0;
  static const Color _diceBackgroundColor = Colors.white;
  static const Color _diceTextColor = Colors.black;
  static const Color _heldBorderColor = Color(0xFFFF6F00);

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

    _animationController.forward();
  }

  @override
  void didUpdateWidget(DiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isHeld != widget.isHeld) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Gets the display text for the dice value.
  String get _faceText => DICE_FACES[widget.value].toString();

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scaleAnimation.value,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _opacityAnimation.value,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: _cardWidth,
            height: _cardHeight,
            decoration: BoxDecoration(
              color: _diceBackgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: widget.isHeld ? _heldBorderColor : Colors.grey.shade300,
                width: _borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _faceText,
                style: GoogleFonts.permanentMarker(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: _diceTextColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
