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

/// Internal widget that renders the dots on a die face.
class _DieDots extends StatelessWidget {
  final int value;

  const _DieDots({required this.value});

  @override
  Widget build(BuildContext context) {
    // Dot positions for each die value
    final positions = _getDotPositions(value);

    return Stack(
      children: positions
          .map(
            (offset) => Positioned(
              left: offset.dx,
              top: offset.dy,
              child: const _DieDot(),
            ),
          )
          .toList(),
    );
  }

  /// Returns the positions of dots for a given die value.
  List<Offset> _getDotPositions(int value) {
    const center = 30.0; // Center of 60x60 container
    const corner = 15.0;
    const mid = 45.0;

    switch (value) {
      case 1:
        return [Offset(center, center)];
      case 2:
        return [Offset(corner, corner), Offset(mid, mid)];
      case 3:
        return [
          Offset(corner, corner),
          Offset(center, center),
          Offset(mid, mid),
        ];
      case 4:
        return [
          Offset(corner, corner),
          Offset(mid, corner),
          Offset(corner, mid),
          Offset(mid, mid),
        ];
      case 5:
        return [
          Offset(corner, corner),
          Offset(mid, corner),
          Offset(center, center),
          Offset(corner, mid),
          Offset(mid, mid),
        ];
      case 6:
        return [
          Offset(corner, corner),
          Offset(mid, corner),
          Offset(corner, center),
          Offset(mid, center),
          Offset(corner, mid),
          Offset(mid, mid),
        ];
      default:
        return [];
    }
  }
}

/// A small black dot representing a pips on a die face.
class _DieDot extends StatelessWidget {
  const _DieDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}
