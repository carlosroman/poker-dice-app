import 'package:flutter/material.dart';

/// A widget that displays a single die face with pips (dots).
///
/// Supports values 1-6 with standard dice pip arrangements.
/// Can be toggled to a "held" state with visual feedback.
class DieWidget extends StatefulWidget {
  /// The value of the die face (1-6).
  final int value;

  /// Whether the die is currently held.
  final bool isHeld;

  /// Callback invoked when the die is tapped.
  final VoidCallback? onTap;

  /// The size of the die in pixels.
  final double size;

  const DieWidget({
    super.key,
    required this.value,
    required this.isHeld,
    this.onTap,
    this.size = 60.0,
  }) : assert(value >= 1 && value <= 6, 'Die value must be between 1 and 6');

  @override
  State<DieWidget> createState() => _DieWidgetState();
}

class _DieWidgetState extends State<DieWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.size * 0.15),
          border: Border.all(
            color: widget.isHeld ? Colors.deepOrange : Colors.grey.shade300,
            width: widget.isHeld ? 3.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isHeld
                  ? Colors.deepOrange.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.15),
              blurRadius: widget.isHeld
                  ? widget.size * 0.25
                  : widget.size * 0.1,
              offset: Offset(
                0,
                widget.isHeld ? widget.size * 0.08 : widget.size * 0.04,
              ),
            ),
          ],
        ),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: EdgeInsets.all(widget.size * 0.12),
              child: _buildPipLayout(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPipLayout() {
    switch (widget.value) {
      case 1:
        return _buildOne();
      case 2:
        return _buildTwo();
      case 3:
        return _buildThree();
      case 4:
        return _buildFour();
      case 5:
        return _buildFive();
      case 6:
        return _buildSix();
      default:
        return _buildOne();
    }
  }

  /// Pip arrangement for value 1: center dot
  Widget _buildOne() {
    return _buildPip();
  }

  /// Pip arrangement for value 2: top-left and bottom-right
  Widget _buildTwo() {
    return _buildPipGrid(
      positions: [
        [true, false],
        [false, true],
      ],
    );
  }

  /// Pip arrangement for value 3: top-left, center, bottom-right
  Widget _buildThree() {
    return _buildPipGrid(
      positions: [
        [true, false, false],
        [false, true, false],
        [false, false, true],
      ],
    );
  }

  /// Pip arrangement for value 4: four corners
  Widget _buildFour() {
    return _buildPipGrid(
      positions: [
        [true, false, true],
        [false, false, false],
        [true, false, true],
      ],
    );
  }

  /// Pip arrangement for value 5: four corners + center
  Widget _buildFive() {
    return _buildPipGrid(
      positions: [
        [true, false, true],
        [false, true, false],
        [true, false, true],
      ],
    );
  }

  /// Pip arrangement for value 6: two columns of three
  Widget _buildSix() {
    return _buildPipGrid(
      positions: [
        [true, false, true],
        [true, false, true],
        [true, false, true],
      ],
    );
  }

  /// Builds a single centered pip
  Widget _buildPip() {
    return Container(
      width: _pipSize,
      height: _pipSize,
      decoration: BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: _pipSize * 0.2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  /// Builds a grid of pips based on the positions matrix
  Widget _buildPipGrid({required List<List<bool>> positions}) {
    final rows = positions.length;
    final cols = positions[0].length;
    final pipSize = _pipSize;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: pipSize * 0.25,
        crossAxisSpacing: pipSize * 0.25,
      ),
      itemCount: rows * cols,
      itemBuilder: (context, index) {
        final row = index ~/ cols;
        final col = index % cols;
        final hasPip = positions[row][col];
        return hasPip
            ? Container(
                width: pipSize,
                height: pipSize,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: pipSize * 0.2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }

  /// Calculates the pip size based on the die size
  double get _pipSize {
    if (widget.value == 1) {
      return widget.size * 0.28;
    }
    // For values 2-6, use a 3x3 grid layout
    if (widget.value == 6) {
      return widget.size * 0.13;
    }
    return widget.size * 0.15;
  }
}
