import 'package:flutter/material.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';
import '../utils/accessibility_utils.dart';

/// A button for rolling dice that shows the current roll count.
///
/// Displays "ROLL" followed by the number of rolls remaining.
/// Disabled and dimmed when max rolls (3) have been reached.
class RollButton extends StatelessWidget {
  /// The current roll count (0-3).
  final int rollCount;

  /// Callback when the button is tapped.
  final VoidCallback? onTap;

  /// Creates a [RollButton].
  const RollButton({super.key, this.rollCount = 0, this.onTap});

  /// Whether the button should be enabled.
  bool get isEnabled => rollCount < 3;

  /// The text to display on the button.
  String get buttonText {
    if (rollCount == 0) {
      return 'ROLL';
    }
    return 'ROLL $rollCount';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AccessibilityUtils.getRollLabel(rollCount, isEnabled),
      button: true,
      enabled: isEnabled,
      child: ElevatedButton(
        onPressed: isEnabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppTheme.surfaceDark : Colors.grey,
          foregroundColor: AppTheme.textOnPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: AppTypography.large,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
