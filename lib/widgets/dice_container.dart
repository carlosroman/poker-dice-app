import 'package:flutter/material.dart';
import '../models/dice_roll.dart';
import '../models/die.dart';
import 'die_widget.dart';

/// A widget that displays a row of 5 dice with hold gesture support.
///
/// This widget displays all dice from a [DiceRoll] in a horizontal row,
/// allowing users to tap each die to toggle its held state. Held dice
/// are visually distinguished with an orange glow effect.
///
/// Example usage:
/// ```dart
/// DiceContainer(
///   diceRoll: myDiceRoll,
///   onDieToggled: (index) => setState(() {
///     diceRoll = diceRoll.toggleDieHeld(index);
///   }),
///   dieSize: 70.0,
/// )
/// ```
class DiceContainer extends StatelessWidget {
  /// The current dice roll to display.
  ///
  /// If null, displays empty placeholders to indicate no roll yet.
  final DiceRoll? diceRoll;

  /// Callback invoked when a die is tapped.
  ///
  /// The [index] parameter indicates which die was tapped (0-4).
  final Function(int index)? onDieToggled;

  /// The size of each die in pixels.
  ///
  /// Defaults to 60.0. All dice will have this size.
  final double dieSize;

  const DiceContainer({
    super.key,
    required this.diceRoll,
    this.onDieToggled,
    this.dieSize = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(dieSize * 0.2),
        decoration: BoxDecoration(
          color: _getContainerColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getShadowColor(context),
              blurRadius: dieSize * 0.2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: _buildDice(context),
        ),
      ),
    );
  }

  /// Builds the list of dice widgets.
  List<Widget> _buildDice(BuildContext context) {
    final List<Widget> diceWidgets = <Widget>[];

    for (int i = 0; i < 5; i++) {
      diceWidgets.add(
        GestureDetector(
          onTap: onDieToggled != null ? () => _handleDieTap(i) : null,
          child: _buildDieForIndex(i),
        ),
      );

      // Add spacing between dice (but not after the last one)
      if (i < 4) {
        diceWidgets.add(SizedBox(width: dieSize * 0.3));
      }
    }

    return diceWidgets;
  }

  /// Builds a die widget for the specified index.
  Widget _buildDieForIndex(int index) {
    if (diceRoll == null) {
      return _buildPlaceholderDie();
    }

    final Die die = diceRoll!.dice[index];
    return DieWidget(
      value: die.value,
      isHeld: die.isHeld,
      size: dieSize,
      onTap: onDieToggled != null ? () => _handleDieTap(index) : null,
    );
  }

  /// Builds a placeholder die when no roll exists.
  Widget _buildPlaceholderDie() {
    return Container(
      width: dieSize,
      height: dieSize,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(dieSize * 0.15),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
    );
  }

  /// Handles the tap gesture on a die.
  void _handleDieTap(int index) {
    if (onDieToggled != null && index >= 0 && index < 5) {
      onDieToggled!(index);
    }
  }

  /// Gets the container background color based on theme.
  Color _getContainerColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.grey.shade50;
  }

  /// Gets the shadow color based on theme.
  Color _getShadowColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.1);
  }
}
