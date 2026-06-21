import 'package:flutter/material.dart';

/// A primary action button that displays a remaining rolls counter badge.
///
/// Used for the dice roll action in the game. Shows a badge with the
/// number of rolls remaining (0-3) and disables when no rolls are left.
class RollButton extends StatelessWidget {
  /// The number of rolls remaining (0-3).
  final int rollsRemaining;

  /// Callback invoked when the button is pressed.
  final VoidCallback? onPressed;

  /// The label text displayed on the button.
  final String label;

  /// Creates a RollButton with the given [rollsRemaining] and [onPressed] callback.
  ///
  /// The [label] defaults to 'Roll'. The button is disabled when [rollsRemaining] is 0.
  const RollButton({
    super.key,
    this.rollsRemaining = 3,
    this.onPressed,
    this.label = 'Roll',
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = rollsRemaining > 0 && onPressed != null;

    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dice icon
          const Icon(Icons.casino, size: 24),
          const SizedBox(width: 8),
          // Label
          Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          // Rolls remaining badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isEnabled
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$rollsRemaining',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
