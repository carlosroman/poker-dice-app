import 'package:flutter/material.dart';

/// A [CustomPainter] that draws the pips (dots) for a standard dice face.
///
/// Supports values from 0 to 6. Value 0 renders a blank face (no pips).
/// Exposed for testing purposes.
class DiceFacePainter extends CustomPainter {
  /// The face value to draw (0-6). Value 0 = blank (no pips).
  final int value;

  /// The color of the pips.
  final Color pipColor;

  /// The radius of each pip.
  final double pipRadius;

  const DiceFacePainter({
    required this.value,
    required this.pipColor,
    required this.pipRadius,
  }) : assert(value >= 0 && value <= 6);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final quarterX = size.width / 4;
    final quarterY = size.height / 4;
    final threeQuarterX = size.width * 3 / 4;
    final threeQuarterY = size.height * 3 / 4;

    final paint = Paint()
      ..color = pipColor
      ..style = PaintingStyle.fill;

    final offsets = _positionsForValue(
      center: center,
      topLeft: Offset(quarterX, quarterY),
      topRight: Offset(threeQuarterX, quarterY),
      bottomLeft: Offset(quarterX, threeQuarterY),
      bottomRight: Offset(threeQuarterX, threeQuarterY),
      midLeft: Offset(quarterX, center.dy),
      midRight: Offset(threeQuarterX, center.dy),
    );

    for (final offset in offsets) {
      canvas.drawCircle(offset, pipRadius, paint);
    }
  }

  List<Offset> _positionsForValue({
    required Offset center,
    required Offset topLeft,
    required Offset topRight,
    required Offset bottomLeft,
    required Offset bottomRight,
    required Offset midLeft,
    required Offset midRight,
  }) {
    switch (value) {
      case 0:
        return [];
      case 1:
        return [center];
      case 2:
        return [topLeft, bottomRight];
      case 3:
        return [topLeft, center, bottomRight];
      case 4:
        return [topLeft, topRight, bottomLeft, bottomRight];
      case 5:
        return [topLeft, topRight, center, bottomLeft, bottomRight];
      case 6:
        return [topLeft, topRight, midLeft, midRight, bottomLeft, bottomRight];
      default:
        return [];
    }
  }

  @override
  bool shouldRepaint(DiceFacePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.pipColor != pipColor ||
        oldDelegate.pipRadius != pipRadius;
  }
}

/// A widget that renders a standard dice face using [CustomPaint].
///
/// Draws pips (dots) for values 1-6 in standard positions. Value 0 renders
/// a blank face with no pips.
/// No image assets are used; everything is drawn programmatically.
///
/// Example:
/// ```dart
/// DiceFace(value: 5, size: 64.0, pipColor: Colors.white)
/// ```
class DiceFace extends StatelessWidget {
  /// The face value to display (0-6). Value 0 = blank (no pips).
  final int value;

  /// The overall size (width and height) of the dice face.
  final double size;

 /// The color of the pips.
  ///
  /// When `null`, the color is derived from the theme brightness:
  /// black for light themes, white for dark themes.
  final Color? pipColor;

  /// The radius of each pip, as a fraction of the dice [size].
  ///
  /// Defaults to 0.12 (12% of the dice size).
  final double pipRadiusFraction;

  /// Creates a [DiceFace] widget.
  ///
  /// The [value] must be between 0 and 6 inclusive. Value 0 renders blank.
  /// The [size] must be positive.
  const DiceFace({
    super.key,
    required this.value,
    this.size = 48.0,
    this.pipColor,
    this.pipRadiusFraction = 0.12,
  }) : assert(value >= 0 && value <= 6),
        assert(size > 0);

  @override
  Widget build(BuildContext context) {
    final resolvedPipColor = pipColor ??
        (Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: DiceFacePainter(
          value: value,
          pipColor: resolvedPipColor,
          pipRadius: size * pipRadiusFraction,
        ),
      ),
    );
  }
}
