import 'package:flutter/material.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';

/// A custom checkbox widget for holding dice in the Yatzy game.
///
/// Provides a styled checkbox with smooth animations and accessibility support.
/// Used to indicate whether a die is held for the next roll.
///
/// ## Features
/// - Animated transitions between states
/// - Custom styling for held/not held states
/// - Accessibility support with semantic labels
/// - Disabled state support
///
/// ## States
/// | State | Appearance | Border |
/// |-------|------------|--------|
/// | Held | Blue fill, white check | Primary color, 2px |
/// | Not Held | Transparent fill | Outline color, 1px |
/// | Disabled | Grey fill | Disabled color, 1px |
///
/// Example:
/// ```dart
/// HoldCheckbox(
///   isHeld: die.held,
///   isEnabled: gameBloc.state.canRoll,
///   onChanged: (value) => gameBloc.add(ToggleDie(index: index)),
/// )
/// ```
class HoldCheckbox extends StatelessWidget {
  /// Whether the checkbox is currently in the held state.
  ///
  /// When true, the die is held and will not be rolled.
  /// When false, the die will be included in the next roll.
  final bool isHeld;

  /// Callback invoked when the checkbox is toggled.
  ///
  /// If null, the checkbox will be visually disabled and not respond to taps.
  /// Typically calls [ValueChanged] with the new held state.
  final ValueChanged<bool?>? onChanged;

  /// Whether the checkbox can be interacted with.
  ///
  /// When false, the checkbox is displayed in a disabled state and
  /// [onChanged] is not called even if provided.
  /// Typically disabled when no rolls are remaining.
  final bool isEnabled;

  /// Creates a [HoldCheckbox] widget.
  ///
  /// The [isHeld] parameter must not be null.
  /// The [isEnabled] parameter defaults to true.
  const HoldCheckbox({
    super.key,
    required this.isHeld,
    this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool canInteract = isEnabled && onChanged != null;

    return SizedBox(
      width: 48.0,
      height: 48.0,
      child: Semantics(
        label: isHeld ? 'Die held' : 'Die not held',
        enabled: canInteract,
        child: IgnorePointer(
          ignoring: !canInteract,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Checkbox(
              value: isHeld,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                side: BorderSide(
                  color: _getBorderColor(context),
                  width: _getBorderWidth(context),
                ),
              ),
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.primaryColor;
                }
                if (!isEnabled) {
                  return AppTheme.disabledColor;
                }
                return Colors.transparent;
              }),
              checkColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Returns the appropriate border color based on state.
  ///
  /// Parameters:
  /// - [context]: BuildContext for theme access
  ///
  /// Returns:
  /// - Disabled color if [isEnabled] is false
  /// - Primary color if [isHeld] is true
  /// - Theme outline color otherwise
  Color _getBorderColor(BuildContext context) {
    if (!isEnabled) {
      return AppTheme.disabledColor;
    }
    if (isHeld) {
      return AppTheme.primaryColor;
    }
    return Theme.of(context).colorScheme.outline;
  }

  /// Returns the appropriate border width based on state.
  ///
  /// Parameters:
  /// - [context]: BuildContext (unused, kept for consistency)
  ///
  /// Returns:
  /// - 2.0 if [isHeld] is true (emphasized border)
  /// - 1.0 otherwise (standard border)
  double _getBorderWidth(BuildContext context) {
    if (isHeld) {
      return 2.0;
    }
    return 1.0;
  }
}
