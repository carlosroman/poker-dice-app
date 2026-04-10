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
/// proper centering of dots from their center point (like the Upper section).
class _DieDotPainter extends CustomPainter {
  final int dots;

  _DieDotPainter({required this.dots});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final dotRadius = 5.0; // Half of 10x10 dot size
    final center = Offset(size.width / 2, size.height / 2);
    final offset = size.width * 0.25; // 15px for 60px container

    // Define dot positions for each value
    final positions = <Offset>[];

    switch (dots) {
      case 1:
        positions.add(center);
        break;
      case 2:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
      case 3:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(center);
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
      case 4:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(Offset(center.dx + offset, center.dy - offset));
        positions.add(Offset(center.dx - offset, center.dy + offset));
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
      case 5:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(Offset(center.dx + offset, center.dy - offset));
        positions.add(center);
        positions.add(Offset(center.dx - offset, center.dy + offset));
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
      case 6:
        final colOffset = offset * 0.8;
        final rowOffset = offset * 1.2;
        positions.add(Offset(center.dx - colOffset, center.dy - rowOffset));
        positions.add(Offset(center.dx + colOffset, center.dy - rowOffset));
        positions.add(Offset(center.dx - colOffset, center.dy));
        positions.add(Offset(center.dx + colOffset, center.dy));
        positions.add(Offset(center.dx - colOffset, center.dy + rowOffset));
        positions.add(Offset(center.dx + colOffset, center.dy + rowOffset));
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
