import 'package:flutter/material.dart';

/// Renders a single die face showing [value] (1-6) as pips on a 3x3 grid.
///
/// When [isHeld] is true, an orange border and overlay indicate the held state.
/// Tapping triggers [onTap] if provided.
class DieWidget extends StatelessWidget {
  /// The die face value to display (1-6).
  final int value;

  /// Whether this die is currently held.
  final bool isHeld;

  /// Called when the die is tapped.
  final VoidCallback? onTap;

  /// The size of the die face in logical pixels. Defaults to 56.
  final double size;

  const DieWidget({
    super.key,
    required this.value,
    this.isHeld = false,
    this.onTap,
    this.size = 56,
  });

  /// Returns true for grid positions that should show a pip for [value].
  static bool _showPip(int value, int row, int col) {
    switch (value) {
      case 1:
        return row == 1 && col == 1;
      case 2:
        return (row == 0 && col == 2) || (row == 2 && col == 0);
      case 3:
        return (row == 0 && col == 2) ||
            (row == 1 && col == 1) ||
            (row == 2 && col == 0);
      case 4:
        return (row == 0 && col == 0) ||
            (row == 0 && col == 2) ||
            (row == 2 && col == 0) ||
            (row == 2 && col == 2);
      case 5:
        return (row == 0 && col == 0) ||
            (row == 0 && col == 2) ||
            (row == 1 && col == 1) ||
            (row == 2 && col == 0) ||
            (row == 2 && col == 2);
      case 6:
        return (row == 0 && col == 0) ||
            (row == 0 && col == 2) ||
            (row == 1 && col == 0) ||
            (row == 1 && col == 2) ||
            (row == 2 && col == 0) ||
            (row == 2 && col == 2);
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pipSize = size * 0.15;

    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(size * 0.08),
          decoration: BoxDecoration(
            color: isHeld
                ? theme.colorScheme.secondaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(size * 0.15),
            border: Border.all(
              color: isHeld
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.outlineVariant,
              width: isHeld ? 2.5 : 1,
            ),
            boxShadow: isHeld
                ? [
                    BoxShadow(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            itemBuilder: (context, index) {
              final row = index ~/ 3;
              final col = index % 3;
              final show = _showPip(value, row, col);

              return Center(
                child: SizedBox(
                  width: pipSize,
                  height: pipSize,
                  child: show
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            color: isHeld
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onSurface,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
