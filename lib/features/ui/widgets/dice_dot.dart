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

  /// Creates a [DiceDot] widget.
  const DiceDot({
    super.key,
    required this.value,
    this.size = 50.0,
    this.pipColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    // Define pip positions based on dice value
    final positions = _getPipPositions(value);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.15),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Stack(
        children: positions.map((position) {
          return Positioned(
            left: position['left'],
            top: position['top'],
            child: Container(
              width: size * 0.18,
              height: size * 0.18,
              decoration: BoxDecoration(
                color: pipColor,
                shape: BoxShape.circle,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Returns the pip positions for a given dice value.
  List<Map<String, double>> _getPipPositions(int value) {
    final positions = <Map<String, double>>[];

    switch (value) {
      case 1:
        // Center pip
        positions.add({'left': 35.0, 'top': 35.0});
        break;
      case 2:
        // Top-left and bottom-right
        positions.add({'left': 10.0, 'top': 10.0});
        positions.add({'left': 60.0, 'top': 60.0});
        break;
      case 3:
        // Top-left, center, bottom-right
        positions.add({'left': 10.0, 'top': 10.0});
        positions.add({'left': 35.0, 'top': 35.0});
        positions.add({'left': 60.0, 'top': 60.0});
        break;
      case 4:
        // Four corners
        positions.add({'left': 10.0, 'top': 10.0});
        positions.add({'left': 60.0, 'top': 10.0});
        positions.add({'left': 10.0, 'top': 60.0});
        positions.add({'left': 60.0, 'top': 60.0});
        break;
      case 5:
        // Four corners + center
        positions.add({'left': 10.0, 'top': 10.0});
        positions.add({'left': 60.0, 'top': 10.0});
        positions.add({'left': 10.0, 'top': 60.0});
        positions.add({'left': 60.0, 'top': 60.0});
        positions.add({'left': 35.0, 'top': 35.0});
        break;
      case 6:
        // Two columns of 3
        positions.add({'left': 10.0, 'top': 10.0});
        positions.add({'left': 60.0, 'top': 10.0});
        positions.add({'left': 10.0, 'top': 35.0});
        positions.add({'left': 60.0, 'top': 35.0});
        positions.add({'left': 10.0, 'top': 60.0});
        positions.add({'left': 60.0, 'top': 60.0});
        break;
      default:
        // Default to empty dice
        break;
    }

    return positions;
  }
}
