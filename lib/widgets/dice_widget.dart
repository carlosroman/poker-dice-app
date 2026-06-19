import 'package:flutter/material.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/widgets/dice_face.dart';

/// A tappable dice widget that displays a [DiceFace] with a held-state indicator.
///
/// When [dice.isHeld] is true, an amber glow border is shown around the die.
/// Tapping the widget invokes [onTap] if provided.
///
/// The [size] controls the overall dimensions of the dice face.
/// Defaults to 48.0.
class DiceWidget extends StatelessWidget {
  /// The dice data to display.
  final Dice dice;

  /// Called when the dice is tapped.
  final VoidCallback? onTap;

  /// The overall size (width and height) of the dice.
  final double size;

  /// The color used for the held-state border glow.
  ///
  /// Defaults to [Colors.amber].
  final Color heldColor;

  /// The width of the held-state border.
  ///
  /// Defaults to 3.0.
  final double heldBorderWidth;

  /// The background color of the dice face.
  ///
  /// Defaults to [ColorScheme.surface] from the current theme, providing
  /// contrast against the dice area (typically [ColorScheme.surfaceContainerHighest]).
  final Color? backgroundColor;

  /// Creates a [DiceWidget].
  const DiceWidget({
    super.key,
    required this.dice,
    this.onTap,
    this.size = 48.0,
    this.heldColor = Colors.amber,
    this.heldBorderWidth = 3.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surface;
    final borderRadius = BorderRadius.circular(size / 6);

    final widget = GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
          border: dice.isHeld
              ? Border.all(color: heldColor, width: heldBorderWidth)
              : null,
        ),
        child: DiceFace(value: dice.value, size: size),
      ),
    );

    return Semantics(
      label: 'Die showing ${dice.value}${dice.isHeld ? ', held' : ''}',
      button: onTap != null,
      child: widget,
    );
  }
}
