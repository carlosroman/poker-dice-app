import 'package:flutter/material.dart';

/// A header widget for the game screen that displays score and player info.
///
/// This widget displays the total score prominently in the center with the
/// player name below it. Optional back and menu buttons can be displayed
/// on the left and right respectively.
///
/// Example usage:
/// ```dart
/// HeaderBar(
///   totalScore: 150,
///   playerName: 'Player 1',
///   onBackPressed: () => Navigator.pop(context),
///   onMenuPressed: () => _showMenu(),
/// )
/// ```
class HeaderBar extends StatelessWidget {
  /// The player's total score to display.
  final int totalScore;

  /// The player name or indicator to display below the score.
  ///
  /// Defaults to 'You' if not provided.
  final String playerName;

  /// Callback invoked when the back button is pressed.
  ///
  /// If null, the back button is not displayed.
  final VoidCallback? onBackPressed;

  /// Callback invoked when the menu button is pressed.
  ///
  /// If null, the menu button is not displayed.
  final VoidCallback? onMenuPressed;

  const HeaderBar({
    super.key,
    required this.totalScore,
    this.playerName = 'You',
    this.onBackPressed,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button (optional)
          _buildBackButton(context),
          const Spacer(flex: 1),

          // Score info (centered)
          _buildScoreInfo(primaryColor, secondaryColor),

          const Spacer(flex: 1),

          // Menu button (optional)
          _buildMenuButton(context),
        ],
      ),
    );
  }

  /// Builds the back button widget.
  Widget _buildBackButton(BuildContext context) {
    if (onBackPressed == null) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: onBackPressed,
      tooltip: 'Back',
    );
  }

  /// Builds the score info widget (score + player name).
  Widget _buildScoreInfo(Color primaryColor, Color secondaryColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Total score - displayed prominently
        Text(
          totalScore.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontFamily: 'Poppins',
          ),
        ),
        // Player name - smaller text below score
        Text(
          playerName,
          style: TextStyle(
            fontSize: 12,
            color: secondaryColor,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  /// Builds the menu button widget.
  Widget _buildMenuButton(BuildContext context) {
    if (onMenuPressed == null) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: onMenuPressed,
      tooltip: 'Menu',
    );
  }
}
