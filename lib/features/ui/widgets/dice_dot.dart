import 'package:flutter/material.dart';

/// A widget that renders dice faces with traditional pips (dots).
///
/// Displays dice values 1-6 with proper pip arrangements:
/// - 1: Center dot
/// - 2: Top-left and bottom-right
/// - 3: Top-left, center, bottom-right
/// - 4: Four corners
/// - 5: Four corners + center
/// - 6: Two columns of 3
class DiceDot extends StatelessWidget {
  /// The dice value (1-6).
  final int value;

  /// The size of the dice face.
  final double size;

  /// The color of the pips.
  final Color pipColor;

  /// Whether to show the white background container.
  /// Set to false for score sheet icons to avoid visibility issues.
  final bool showBackground;

  /// Creates a [DiceDot] widget.
  const DiceDot({
    super.key,
    required this.value,
    this.size = 50.0,
    this.pipColor = Colors.black,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    // Define pip positions based on dice value
    final positions = _getPipPositions(value);

    final pipsWidget = Stack(
      children: positions.map((position) {
        return Positioned(
          left: position['left']! * size,
          top: position['top']! * size,
          child: Container(
            width: size * 0.20,
            height: size * 0.20,
            decoration: BoxDecoration(color: pipColor, shape: BoxShape.circle),
          ),
        );
      }).toList(),
    );

    if (showBackground) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.15),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
        ),
        child: pipsWidget,
      );
    } else {
      // No background - just pips (for score sheet icons)
      return SizedBox(width: size, height: size, child: pipsWidget);
    }
  }

  /// Returns the pip positions for a given dice value.
  ///
  /// Positions are returned as percentages (0.0 to 1.0) of the dice size.
  List<Map<String, double>> _getPipPositions(int value) {
    final positions = <Map<String, double>>[];

    switch (value) {
      case 1:
        // Center pip (50%)
        positions.add({'left': 0.5, 'top': 0.5});
        break;
      case 2:
        // Top-left (20%) and bottom-right (80%)
        positions.add({'left': 0.2, 'top': 0.2});
        positions.add({'left': 0.8, 'top': 0.8});
        break;
      case 3:
        // Top-left, center, bottom-right
        positions.add({'left': 0.2, 'top': 0.2});
        positions.add({'left': 0.5, 'top': 0.5});
        positions.add({'left': 0.8, 'top': 0.8});
        break;
      case 4:
        // Four corners
        positions.add({'left': 0.2, 'top': 0.2});
        positions.add({'left': 0.8, 'top': 0.2});
        positions.add({'left': 0.2, 'top': 0.8});
        positions.add({'left': 0.8, 'top': 0.8});
        break;
      case 5:
        // Four corners + center
        positions.add({'left': 0.2, 'top': 0.2});
        positions.add({'left': 0.8, 'top': 0.2});
        positions.add({'left': 0.2, 'top': 0.8});
        positions.add({'left': 0.8, 'top': 0.8});
        positions.add({'left': 0.5, 'top': 0.5});
        break;
      case 6:
        // Two columns of 3 (at 20% and 80%, with rows at 20%, 50%, 80%)
        positions.add({'left': 0.2, 'top': 0.2});
        positions.add({'left': 0.8, 'top': 0.2});
        positions.add({'left': 0.2, 'top': 0.5});
        positions.add({'left': 0.8, 'top': 0.5});
        positions.add({'left': 0.2, 'top': 0.8});
        positions.add({'left': 0.8, 'top': 0.8});
        break;
      default:
        // Default to empty dice
        break;
    }

    return positions;
  }
}
