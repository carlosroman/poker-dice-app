import 'package:flutter/material.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';

/// A button component for rolling dice in the Yatzy game.
///
/// Displays the number of remaining rolls and provides visual feedback
/// for enabled/disabled states with smooth animations.
///
/// ## Features
/// - Animated transitions between enabled/disabled states
/// - Dynamic text showing remaining rolls
/// - Icon changes based on enabled state
/// - Fade and scale transitions
///
/// ## States
/// | State | Icon | Text | Background |
/// |-------|------|------|------------|
/// | Enabled | Diamond | "Roll Dice (N left)" | Primary color |
/// | Disabled | Block | "Roll Dice" | Disabled color |
///
/// Example:
/// ```dart
/// RollButton(
///   isEnabled: gameBloc.state.canRoll,
///   remainingRolls: gameBloc.state.remainingRolls,
///   onPressed: () => gameBloc.add(RollDice()),
/// )
/// ```
class RollButton extends StatelessWidget {
  /// Whether the button can be pressed.
  ///
  /// When true, the button is interactive with primary color background.
  /// When false, the button is disabled with grey background.
  final bool isEnabled;

  /// Number of rolls remaining (0-2).
  ///
  /// Displayed in the button text as "Roll Dice (N left)".
  /// When 0, shows "Roll Dice" without the count.
  final int remainingRolls;

  /// Callback invoked when the button is pressed.
  ///
  /// Only invoked when [isEnabled] is true.
  /// Typically triggers the dice roll action.
  final VoidCallback? onPressed;

  /// Creates a [RollButton] for rolling dice.
  ///
  /// The [isEnabled] and [remainingRolls] parameters must not be null.
  const RollButton({
    super.key,
    required this.isEnabled,
    required this.remainingRolls,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isEnabled
        ? AppTheme.primaryColor
        : AppTheme.disabledColor;
    final Color foregroundColor = AppTheme.textOnSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 4,
          shadowColor: AppTheme.shadowMedium.first.color,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLg,
            vertical: AppTheme.spacingMd,
          ),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isEnabled ? Icons.diamond : Icons.block,
                key: ValueKey<bool>(isEnabled),
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                _getButtonText(),
                key: ValueKey<int>(remainingRolls),
                style: const TextStyle(
                  fontSize: AppTheme.buttonSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the button text based on remaining rolls.
  ///
  /// Parameters:
  /// - No parameters - uses [remainingRolls] field
  ///
  /// Returns:
  /// - "Roll Dice" when remainingRolls is 0
  /// - "Roll Dice (N left)" when remainingRolls > 0
  String _getButtonText() {
    if (remainingRolls == 0) {
      return 'Roll Dice';
    }
    return 'Roll Dice ($remainingRolls left)';
  }
}
