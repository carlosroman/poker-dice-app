import 'package:flutter/material.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';
import '../utils/accessibility_utils.dart';

/// A button for selecting a score category.
///
/// White button with orange "PLAY" text.
/// Enabled when user has rolled and has empty categories.
class PlayButton extends StatelessWidget {
  /// Whether the button is enabled.
  final bool isEnabled;

  /// Callback when the button is tapped.
  final VoidCallback? onTap;

  /// Creates a [PlayButton].
  const PlayButton({super.key, this.isEnabled = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AccessibilityUtils.getPlayLabel(isEnabled),
      button: true,
      enabled: isEnabled,
      child: OutlinedButton(
        onPressed: isEnabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: isEnabled ? AppTheme.accentOrange : Colors.grey,
          side: BorderSide(
            color: isEnabled ? AppTheme.accentOrange : Colors.grey,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'PLAY',
          style: TextStyle(
            fontSize: AppTypography.large,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
