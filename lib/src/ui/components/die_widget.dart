import 'package:flutter/material.dart';
import '../utils/accessibility_utils.dart';

/// A widget that displays a single die face with dots representing the value.
///
/// The die is displayed as a white rounded square with black dots.
/// When held, it shows an orange border to indicate selection.
/// When value is 0, displays a blank die.
class DieWidget extends StatelessWidget {
  /// The value of the die (0-6).
  /// 0 represents a blank/unrolled die.
  final int value;

  /// Whether the die is currently held/selected.
  final bool isHeld;

  /// Optional callback when the die is tapped.
  final VoidCallback? onTap;

  /// Whether the die is blank (not yet rolled).
  final bool isBlank;

  /// Creates a [DieWidget].
  ///
  /// The [value] must be between 0 and 6.
  /// The [isHeld] defaults to false.
  /// The [isBlank] defaults to false.
  const DieWidget({
    super.key,
    required this.value,
    this.isHeld = false,
    this.onTap,
    this.isBlank = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBlank ? null : onTap,
      child: Semantics(
        label: isBlank
            ? 'Blank die'
            : AccessibilityUtils.getDieLabel(value, isHeld: isHeld),
        button: !isBlank,
        selected: isHeld,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isBlank ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: isHeld && !isBlank
                ? Border.all(color: Colors.orange, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isBlank ? const _BlankDieFace() : _DieDots(value: value),
        ),
      ),
    );
  }
}

/// Internal widget that displays a blank die face.
class _BlankDieFace extends StatelessWidget {
  const _BlankDieFace();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.remove, color: Colors.grey, size: 30),
    );
  }
}

/// Internal widget that renders the dots on a die face using CustomPainter.
class _DieDots extends StatelessWidget {
  final int value;

  const _DieDots({required this.value});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(60, 60),
      painter: _DieDotPainter(dots: value),
    );
  }
}

/// Custom painter for die dots.
///
/// This painter draws dots on a die face using Canvas API, ensuring
/// proper centering of dots from their center point.
/// Uses precise pixel-based positioning to match traditional dice patterns.
class _DieDotPainter extends CustomPainter {
  final int dots;

  _DieDotPainter({required this.dots});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final dotRadius = 5.0;

    // Precise positions for a 60x60 die
    // Center of each dot position
    const center = 30.0; // Center of 60x60
    const corner = 15.0; // Corner position (15px from edge)
    const edge = 45.0; // Edge position (45px from origin)

    final positions = <Offset>[];

    switch (dots) {
      case 1:
        // Single dot in center
        positions.add(Offset(center, center));
        break;
      case 2:
        // Diagonal from top-left to bottom-right
        positions.add(Offset(corner, corner));
        positions.add(Offset(edge, edge));
        break;
      case 3:
        // Diagonal with center
        positions.add(Offset(corner, corner));
        positions.add(Offset(center, center));
        positions.add(Offset(edge, edge));
        break;
      case 4:
        // Four corners
        positions.add(Offset(corner, corner));
        positions.add(Offset(edge, corner));
        positions.add(Offset(corner, edge));
        positions.add(Offset(edge, edge));
        break;
      case 5:
        // Four corners + center
        positions.add(Offset(corner, corner));
        positions.add(Offset(edge, corner));
        positions.add(Offset(center, center));
        positions.add(Offset(corner, edge));
        positions.add(Offset(edge, edge));
        break;
      case 6:
        // Two columns of 3 dots each
        // Left column: x=15, right column: x=45
        // Top: y=12, middle: y=30, bottom: y=48
        positions.add(Offset(corner, 12.0));
        positions.add(Offset(edge, 12.0));
        positions.add(Offset(corner, center));
        positions.add(Offset(edge, center));
        positions.add(Offset(corner, 48.0));
        positions.add(Offset(edge, 48.0));
        break;
    }

    // Draw all dots
    for (final pos in positions) {
      canvas.drawCircle(pos, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DieDotPainter oldDelegate) =>
      oldDelegate.dots != dots;
}
